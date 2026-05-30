(* ::Package:: *)

(*
   TALBOT EFFECT — SELF-IMAGING OF A PERIODIC GRATING
   
   Beautiful demonstration of near-field diffraction.
   A periodic amplitude or phase grating re-images at regular
   "Talbot distances" z_T = 2 p^2 / λ (and fractional planes).
   
   This is one of the cleanest and most visually striking
   wave optics demos possible in Wolfram Language.
*)

ClearAll["Global`*"];

λ = 532 * 10^-9;     (* 532 nm *)
ps = 2 * 10^-6;      (* fine sampling for clean fringes *)
n = 512;
L = n * ps;

x = ps * Range[-n/2, n/2 - 1];
{X, Y} = {Outer[Times, x, ConstantArray[1, n]],
          Outer[Times, ConstantArray[1, n], x]};

(* Reusable angular spectrum propagator *)
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

(* Periodic grating (amplitude) *)
period = 40 * ps;   (* grating period in meters *)
grating = 0.5 + 0.5 Sign[Sin[2 Pi X / period]];   (* binary amplitude grating *)

(* Precompute Talbot distance for reference *)
talbotZ = 2 period^2 / λ;

Manipulate[
  field = ASPropagate[grating, z, λ, ps];
  intensity = Abs[field]^2;
  
  GraphicsRow[
    {
      ArrayPlot[
        grating,
        ColorFunction -> "GrayTones",
        PlotLabel -> "Grating (z=0)",
        ImageSize -> 240
      ],
      ArrayPlot[
        intensity,
        ColorFunction -> "TemperatureMap",
        PlotLabel -> Row[{"z = ", NumberForm[z * 1000, {6, 3}], " mm"}],
        ImageSize -> 240
      ],
      ListPlot[
        intensity[[n/2]],
        Joined -> True,
        PlotRange -> {0, 1.05},
        ImageSize -> 300,
        PlotLabel -> "Horizontal slice"
      ]
    },
    Spacings -> 12
  ],
  
  {{z, talbotZ / 2, "Propagation distance z (m)"}, 0, 2 talbotZ, talbotZ/40,
   Appearance -> "Labeled", ImageSize -> Large},
  
  (* Quick jump buttons *)
  Row[{
    Button["z = 0 (grating)", z = 0],
    Button["z = z_T / 2 (half Talbot)", z = talbotZ/2],
    Button["z = z_T (full Talbot, self-image)", z = talbotZ],
    Button["z = 2 z_T", z = 2 talbotZ]
  }],
  
  SynchronousUpdating -> False,
  ContinuousAction -> False,
  TrackedSymbols :> {z},
  SaveDefinitions -> True
]

(* ============================================================ *)
(* SCRIPT MODE SUPPORT                                          *)
(* ============================================================ *)

ExportTalbotImages[] := Module[{},
  Print["Exporting Talbot effect images..."];
  
  Export[
    FileNameJoin[{$HomeDirectory, "talbot-effect.png"}],
    GraphicsRow[{
      ArrayPlot[grating, ColorFunction -> "GrayTones"],
      ArrayPlot[ASPropagate[grating, talbotZ/2, λ, ps]^2 // Abs // Rescale, 
        ColorFunction -> "TemperatureMap"],
      ArrayPlot[ASPropagate[grating, talbotZ, λ, ps]^2 // Abs // Rescale, 
        ColorFunction -> "TemperatureMap"]
    }],
    ImageResolution -> 200
  ];
  Print["  → ~/talbot-effect.png  (grating | z_T/2 | z_T)"];
  
  Print["Done."];
];

If[Length[$ScriptCommandLine] > 0,
  ExportTalbotImages[],
  Print["Talbot effect demo loaded. Evaluate the Manipulate above."];
  Print["Call ExportTalbotImages[] to export from script."];
];
