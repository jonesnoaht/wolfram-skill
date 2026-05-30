(* ::Package:: *)

(*
   REUSABLE HIGH-QUALITY GIF EXPORTER FOR MANIPULATE-STYLE PHYSICS DEMOS
   
   Drop this into any notebook and call ExportPhysicsGIF[...]
   
   Handles proper frame generation, duration, looping, and resolution.
*)

ClearAll[ExportPhysicsGIF];

ExportPhysicsGIF[
  graphicsFunc_ : (_Function | _Symbol),   (* function of parameter(s) -> Graphics/Graphics3D *)
  paramSpec_ : {param_, min_, max_, step_}, (* {t, 0, 10, 0.1} style *)
  filename_String,
  opts___ 
] := Module[
  {frames, duration, frameCount, effectiveStep, tmin, tmax, tstep},
  
  {param, tmin, tmax, tstep} = paramSpec;
  effectiveStep = tstep;
  frameCount = Floor[(tmax - tmin)/effectiveStep] + 1;
  
  Print["Generating ", frameCount, " frames for GIF..."];
  
  frames = Table[
    graphicsFunc[Evaluate[param /. param -> t]],
    {t, tmin, tmax, effectiveStep}
  ];
  
  duration = Lookup[{opts}, "Duration", 8]; (* seconds *)
  frameDelay = duration / frameCount;
  
  Export[
    filename,
    frames,
    "GIF",
    "AnimationRepetitions" -> Lookup[{opts}, "Repetitions", Infinity],
    "DisplayDurations" -> Table[frameDelay, frameCount],
    ImageResolution -> Lookup[{opts}, ImageResolution, 150],
    ImageSize -> Lookup[{opts}, ImageSize, 600],
    Sequence @@ FilterRules[{opts}, Except[{ImageResolution, ImageSize, "Duration", "Repetitions"}]]
  ];
  
  Print["Exported to: ", filename];
  filename
];

(* ============================================================ *)
(* USAGE EXAMPLE (uncomment and adapt) *)
(* ============================================================ *)

(*
(* Suppose you have a function that returns a Graphics given time t *)
makeFrame[t_] := Graphics[{
  Red, Disk[{Sin[t], Cos[t]}, 0.2],
  Blue, Disk[{Sin[2 t], Cos[2 t]}, 0.1]
}, PlotRange -> 1.3];

ExportPhysicsGIF[
  makeFrame,
  {t, 0, 2 π, 0.05},
  FileNameJoin[{$HomeDirectory, "orbit-demo.gif"}],
  "Duration" -> 6,
  ImageResolution -> 200,
  ImageSize -> 500
]
*)

(* For a full Manipulate-derived animation, first extract the frame-generating expression,
   then wrap it in a pure function of the time/parameter variable. *)
