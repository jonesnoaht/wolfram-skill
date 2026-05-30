(* ::Package:: *)

(*
   KINOFORM HOLOGRAM OF THE LETTER "W"
   
   Phase-only computer-generated hologram (kinoform) of the letter W.
   Ready-to-run example using the patterns from the wolfram skill.
   
   USAGE:
   - In a notebook (recommended for exploration):
       Open this file in Mathematica/Wolfram Desktop and evaluate.
       The interactive Manipulate will appear.
   
   - From command line / wolframscript (great for batch/export):
       wolframscript -f holography-kinoform-W.wl
       This will automatically export several PNGs and a GIF.
   
   Features:
   - High-quality text rendering of "W"
   - Random phase diffuser
   - Iterative Gerchberg-Saxton kinoform (much better than naive)
   - Exports ready for SLM use
*)

ClearAll["Global`*"];

(* === Physical & numerical parameters === *)
λ   = 532 * 10^-9;      (* 532 nm green laser *)
ps  = 8 * 10^-6;        (* 8 µm pixel pitch — common for SLMs *)
n   = 512;              (* 512×512 grid — good balance of speed/quality *)
zHolo = 0.045;          (* distance from object plane to hologram plane (m) *)

(* Coordinate grids *)
x = ps * Range[-n/2, n/2 - 1];
{X, Y} = {
  Outer[Times, x, ConstantArray[1, n]],
  Outer[Times, ConstantArray[1, n], x]
};

(* Angular Spectrum Propagator (core function) *)
ASPropagate[field_ComplexMatrix, z_?NumericQ, λ_?NumericQ, dx_?NumericQ] := 
  Module[{nx, df, fx, fy, kx, ky, kz, H, F},
    nx = Length[field];
    df = 1/(nx dx);
    fx = RotateRight[Range[-nx/2, nx/2 - 1] df, Floor[nx/2]];
    fy = fx;
    kx = 2 Pi Outer[Times, fx, ConstantArray[1, nx]];
    ky = 2 Pi Outer[Times, ConstantArray[1, nx], fy];
    kz = Sqrt[(2 Pi/λ)^2 - kx^2 - ky^2 + 0. I];
    H = Exp[I kz z] UnitStep[Re[kz]];  (* evanescent filter *)
    F = Fourier[field, FourierParameters -> {0, -1}];
    InverseFourier[F H, FourierParameters -> {0, -1}]
  ];

(* === Create object: the letter "W" with random phase diffuser === *)
letterImg = ImageData[
  Rasterize[
    Style["W", FontFamily -> "Helvetica", FontSize -> 220, Bold, FontColor -> Black],
    RasterSize -> n, 
    ImageSize -> n,
    Background -> White
  ]
][[All, All, 1]];   (* 0 = white, 1 = black *)

object = (1 - letterImg) * Exp[I RandomReal[{-Pi, Pi}, {n, n}]];

(* Propagate object to hologram plane *)
objectAtHolo = ASPropagate[object, zHolo, λ, ps];

(* === Naive direct kinoform === *)
kinoformNaive = Exp[I Arg[objectAtHolo]];

(* === Iterative Gerchberg-Saxton refinement (much better quality) === *)
gerchbergSaxtonKinoform[objectFieldAtHolo_, iterations_: 10] := Module[
  {holoPhase = Exp[I Arg[objectFieldAtHolo]], objPlane, holoPlane},
  Do[
    objPlane  = ASPropagate[holoPhase, -zHolo, λ, ps];
    objPlane  = Abs[objectFieldAtHolo] * Exp[I Arg[objPlane]];
    holoPlane = ASPropagate[objPlane, zHolo, λ, ps];
    holoPhase = Exp[I Arg[holoPlane]],
    iterations
  ];
  holoPhase
];

kinoformIter = gerchbergSaxtonKinoform[objectAtHolo, 12];   (* 12 iterations is usually excellent *)

(* Reconstruction function *)
reconstruct[phaseHolo_, zRec_] := ASPropagate[phaseHolo, zRec, λ, ps];

(* === INTERACTIVE DEMO === *)
Manipulate[
  kino = If[useIterative, kinoformIter, kinoformNaive];
  rec  = reconstruct[kino, zRec];
  int  = Abs[rec]^2 // Rescale;
  
  GraphicsRow[
    {
      (* Original object amplitude *)
      ArrayPlot[
        Abs[objectAtHolo]^2,
        ColorFunction -> "SunsetColors",
        PlotLabel -> Style["Target amplitude at hologram plane", 11, Bold],
        ImageSize -> 240,
        Frame -> False
      ],
      
      (* Kinoform phase pattern (what an SLM would display) *)
      ArrayPlot[
        Arg[kino] // Rescale,
        ColorFunction -> "Rainbow",
        PlotLabel -> Style[
          If[useIterative, "Iterative Kinoform (phase only)", "Naive Kinoform (phase only)"],
          11, Bold
        ],
        ImageSize -> 240,
        Frame -> False
      ],
      
      (* Reconstructed intensity *)
      ArrayPlot[
        int,
        ColorFunction -> "TemperatureMap",
        PlotLabel -> Style[
          Row[{"Reconstructed intensity  z = ", NumberForm[zRec*1000, {5, 1}], " mm"}],
          11, Bold
        ],
        ImageSize -> 240,
        Frame -> False
      ]
    },
    Spacings -> 10,
    ImageSize -> 780
  ],
  
  (* Controls *)
  {{zRec, zHolo, "Reconstruction distance (m)"}, 0.015, 0.09, 0.0005,
   Appearance -> "Labeled", ImageSize -> Large},
  
  {{useIterative, True, "Use Gerchberg-Saxton iteration"}, {True, False},
   ControlType -> Checkbox},
  
  Button["Export current reconstruction as PNG",
    Export[
      FileNameJoin[{$HomeDirectory, "kinoform-W-reconstruction.png"}],
      ArrayPlot[int, ColorFunction -> "TemperatureMap"],
      ImageResolution -> 250
    ];
    Print["Saved high-res PNG to ~/kinoform-W-reconstruction.png"]
  ],
  
  TrackedSymbols :> {zRec, useIterative},
  SynchronousUpdating -> False,
  ContinuousAction -> False,
  SaveDefinitions -> True,
  Initialization :> (
    Print["Kinoform of letter W ready. 12 GS iterations computed."];
    Print["Toggle the checkbox to compare naive vs iterative version."]
  )
]


(* ============================================================ *)
(* SCRIPT / BATCH MODE SUPPORT                                  *)
(* ============================================================ *)

ExportKinoformW[] := Module[{},
  Print["Exporting kinoform images for letter W..."];
  
  (* 1. The phase-only kinoform (what you load onto an SLM) *)
  Export[
    FileNameJoin[{$HomeDirectory, "W-kinoform-phase.png"}],
    Image[Rescale[Arg[kinoformIter]], "Byte"],
    ImageResolution -> 300
  ];
  Print["  → ~/W-kinoform-phase.png  (phase pattern for SLM)"];
  
  (* 2. Reconstructed intensity at the design distance *)
  Export[
    FileNameJoin[{$HomeDirectory, "W-kinoform-reconstruction.png"}],
    ArrayPlot[
      Abs[reconstruct[kinoformIter, zHolo]]^2 // Rescale,
      ColorFunction -> "TemperatureMap",
      Frame -> False
    ],
    ImageResolution -> 250
  ];
  Print["  → ~/W-kinoform-reconstruction.png"];
  
  (* 3. Small GIF showing reconstruction quality vs distance *)
  Export[
    FileNameJoin[{$HomeDirectory, "W-kinoform-reconstruction.gif"}],
    Table[
      ArrayPlot[
        Abs[reconstruct[kinoformIter, z]]^2 // Rescale,
        ColorFunction -> "TemperatureMap",
        Frame -> False
      ],
      {z, 0.02, 0.08, 0.003}
    ],
    "AnimationRepetitions" -> Infinity
  ];
  Print["  → ~/W-kinoform-reconstruction.gif  (vs distance)"];
  
  Print["Done. Check your home directory."];
];

(* Dual-mode dispatch *)
If[Length[$ScriptCommandLine] > 0,
  (* Running via wolframscript -f → batch export mode *)
  ExportKinoformW[],
  
  (* Running in notebook / interactive frontend → show Manipulate *)
  Print["Kinoform of letter W loaded."];
  Print["Evaluate the Manipulate above for the interactive version."];
  Print["You can also call ExportKinoformW[] manually to export images."];
]
