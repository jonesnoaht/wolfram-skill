(* ::Package:: *)

(*
   PHASE-ONLY KINOFORM HOLOGRAM (COMPUTER GENERATED)
   
   Phase-only holograms are what most spatial light modulators (SLMs)
   actually display. No amplitude control — only phase.
   
   This example shows:
   - Direct kinoform (just take Arg of object field)
   - Basic Gerchberg-Saxton style iteration for better reconstruction
   
   Extremely practical for real holographic display work.
*)

ClearAll["Global`*"];

λ = 532 * 10^-9;
ps = 8 * 10^-6;   (* typical SLM pixel pitch *)
n = 512;
L = n * ps;
k = 2 Pi / λ;

x = ps * Range[-n/2, n/2 - 1];
{X, Y} = {Outer[Times, x, ConstantArray[1, n]],
          Outer[Times, ConstantArray[1, n], x]};

ASPropagate[field_, z_, lam_, dx_] := Module[
  {nx = Length[field], df, fx, fy, kx, ky, kz, H, F},
  df = 1/(nx dx);
  fx = RotateRight[Range[-nx/2, nx/2-1] df, Floor[nx/2]];
  fy = fx;
  kx = 2 Pi Outer[Times, fx, ConstantArray[1, nx]];
  ky = 2 Pi Outer[Times, ConstantArray[1, nx], fy];
  kz = Sqrt[(2 Pi/lam)^2 - kx^2 - ky^2 + 0. I];
  H = Exp[I kz z] UnitStep[Re[kz]];
  F = Fourier[field, FourierParameters -> {0, -1}];
  InverseFourier[F H, FourierParameters -> {0, -1}]
];

(* Object: text "SLM" with random phase diffuser *)
letterImg = ImageData[
  Rasterize[Style["SLM", FontFamily -> "Helvetica", FontSize -> 160, Bold],
    RasterSize -> n, ImageSize -> n]
][[All, All, 1]];
object = (1 - letterImg) * Exp[I RandomReal[{-Pi, Pi}, {n, n}]];

(* Propagation distance to hologram plane *)
zHolo = 0.04;

(* Field at hologram plane *)
objectAtHolo = ASPropagate[object, zHolo, λ, ps];

(* === Direct kinoform (naive) === *)
kinoformNaive = Exp[I Arg[objectAtHolo]];

(* === Simple iterative Gerchberg-Saxton style refinement === *)
gerchbergSaxtonKinoform[objectFieldAtHolo_, iterations_: 8] := Module[
  {holoPhase = Exp[I Arg[objectFieldAtHolo]], objPlane, holoPlane},
  Do[
    (* Propagate to object plane, enforce amplitude constraint *)
    objPlane = ASPropagate[holoPhase, -zHolo, λ, ps];
    objPlane = Abs[objectFieldAtHolo] * Exp[I Arg[objPlane]];
    
    (* Propagate back to hologram plane, enforce phase-only constraint *)
    holoPlane = ASPropagate[objPlane, zHolo, λ, ps];
    holoPhase = Exp[I Arg[holoPlane]],
    iterations
  ];
  holoPhase
];

kinoformIter = gerchbergSaxtonKinoform[objectAtHolo, 12];

(* Reconstruction with plane wave illumination *)
reconstruct[phaseHolo_, zRec_] := ASPropagate[phaseHolo, zRec, λ, ps];

Manipulate[
  kino = If[useIterative, kinoformIter, kinoformNaive];
  rec = reconstruct[kino, zRec];
  
  GraphicsRow[
    {
      ArrayPlot[
        Abs[objectAtHolo]^2,
        ColorFunction -> "SunsetColors",
        PlotLabel -> "Target at hologram plane",
        ImageSize -> 240
      ],
      ArrayPlot[
        Arg[kino] // Rescale,
        ColorFunction -> "Rainbow",
        PlotLabel -> If[useIterative, "Iterative Kinoform (phase)", "Direct Kinoform (phase)"],
        ImageSize -> 240
      ],
      ArrayPlot[
        Abs[rec]^2 // Rescale,
        ColorFunction -> "TemperatureMap",
        PlotLabel -> Row[{"Reconstruction at z = ", NumberForm[zRec*1000, {5, 1}], " mm"}],
        ImageSize -> 240
      ]
    },
    Spacings -> 8
  ],
  
  {{zRec, zHolo, "Reconstruction distance (m)"}, 0.01, 0.08, 0.0005, Appearance -> "Labeled"},
  {{useIterative, True, "Use iterative (Gerchberg-Saxton)"}, {True, False}},
  
  SynchronousUpdating -> False
]

(* ============================================================ *)
(* SCRIPT MODE SUPPORT                                          *)
(* ============================================================ *)

ExportKinoformDemo[] := Module[{},
  Print["Exporting generic kinoform demo..."];
  
  Export[
    FileNameJoin[{$HomeDirectory, "kinoform-demo.png"}],
    GraphicsRow[{
      ArrayPlot[Abs[objectAtHolo]^2, ColorFunction -> "SunsetColors"],
      ArrayPlot[Arg[kinoformIter] // Rescale, ColorFunction -> "Rainbow"],
      ArrayPlot[Abs[reconstruct[kinoformIter, zHolo]]^2 // Rescale, 
        ColorFunction -> "TemperatureMap"]
    }],
    ImageResolution -> 200
  ];
  Print["  → ~/kinoform-demo.png"];
  
  Print["Done."];
];

If[Length[$ScriptCommandLine] > 0,
  ExportKinoformDemo[];
  Exit[0],
  Print["Kinoform demo loaded (generic version)."];
  Print["Evaluate the Manipulate above for interactive use."];
];
