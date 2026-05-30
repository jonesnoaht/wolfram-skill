(* ::Package:: *)

(*
   GAUSSIAN BEAM PROPAGATION — ASM VALIDATION DEMO
   
   This is the #1 smoke test for any angular spectrum implementation.
   A centered Gaussian at z=0 should remain Gaussian (within sampling)
   after propagation. Use this to verify your propagator before doing
   holography or other serious wave work.
*)

ClearAll["Global`*"];

λ = 532 * 10^-9;
ps = 4 * 10^-6;
n = 256;                (* smaller grid is fine for this test *)
L = n * ps;
k = 2 π / λ;

x = ps * Range[-n/2, n/2 - 1];
{X, Y} = {
  Outer[Times, x, ConstantArray[1, n]],
  Outer[Times, ConstantArray[1, n], x]
};

(* Reusable ASM — same as in holography example *)
ASPropagate[field_, z_, lam_, dx_] := Module[
  {nx = Length[field], df, fx, fy, kx, ky, kz, H, F},
  df = 1/(nx dx);
  fx = RotateRight[Range[-nx/2, nx/2-1] df, Floor[nx/2]];
  fy = fx;
  kx = 2 π Outer[Times, fx, ConstantArray[1, nx]];
  ky = 2 π Outer[Times, ConstantArray[1, nx], fy];
  kz = Sqrt[(2 π/lam)^2 - kx^2 - ky^2 + 0. I];
  H = Exp[I kz z] UnitStep[Re[kz]];
  F = Fourier[field, FourierParameters -> {0, -1}];
  InverseFourier[F H, FourierParameters -> {0, -1}]
];

(* Initial waist *)
w0 = L/10;
field0 = Exp[-((X)^2 + (Y)^2)/(2 w0^2)];

(* Propagate to several distances *)
Manipulate[
  fieldZ = ASPropagate[field0, z, λ, ps];
  intensityZ = Abs[fieldZ]^2;
  
  GraphicsRow[
    {
      ArrayPlot[
        Abs[field0]^2,
        ColorFunction -> "SunsetColors",
        PlotLabel -> "z = 0 (waist)",
        ImageSize -> 260
      ],
      ArrayPlot[
        intensityZ,
        ColorFunction -> "SunsetColors",
        PlotLabel -> Row[{"z = ", NumberForm[z*1000, {5, 1}], " mm"}],
        ImageSize -> 260
      ],
      ListPlot[
        {Abs[field0[[n/2]]]^2, Abs[fieldZ[[n/2]]]^2},
        Joined -> True,
        PlotRange -> All,
        PlotLegends -> {"z=0", "z = " <> ToString[NumberForm[z*1000, {4, 1}]] <> " mm"},
        ImageSize -> 280,
        PlotLabel -> "Central slice (should stay Gaussian)"
      ]
    },
    Spacings -> 15
  ],
  
  {{z, 0.02, "Propagation distance (m)"}, 0.001, 0.15, 0.001, Appearance -> "Labeled"},
  SynchronousUpdating -> False
]

(* Expected behavior:
   - The beam should spread symmetrically.
   - Central slice should remain very close to Gaussian.
   - If it develops ripples or asymmetry → bug in frequency centering or evanescent filter.
*)
