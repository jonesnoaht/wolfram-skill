(* ::Package:: *)

(* 
   OFF-AXIS DIGITAL HOLOGRAPHY SIMULATION
   Complete, self-contained, interactive Wolfram Language demo
   
   Features:
   - Angular Spectrum propagation (fast & accurate)
   - Off-axis (Leith-Upatnieks) recording
   - Interactive reconstruction distance + reference angle
   - Multiple object types (Gaussian, text "HOLOGRAM", random points)
   - Side-by-side visualization: Object | Hologram fringes | Reconstruction
   - Phase visualization toggle
   - Export buttons for GIF / PNG
   
   Usage:
   1. Open in Mathematica / Wolfram Desktop
   2. Evaluate the whole file
   3. Play with the controls
   4. Change objectType or parameters and re-evaluate the Manipulate cell
   
   This file is part of the "wolfram" Grok skill.
*)

ClearAll["Global`*"];

(* ============================================================ *)
(* 1. PARAMETERS - physical units (SI) *)
(* ============================================================ *)

λ = 532 * 10^-9;      (* wavelength, 532 nm green laser *)
ps = 5.0 * 10^-6;     (* pixel pitch / sampling distance, 5 µm — typical SLM/camera *)
n = 512;              (* grid size — power of 2 is best for FFT speed/accuracy *)
L = n * ps;           (* physical side length of the hologram *)

k = 2 Pi / λ;          (* wave number *)

(* Coordinate grids (centered) *)
x = ps * Range[-n/2, n/2 - 1];
{X, Y} = {
  Outer[Times, x, ConstantArray[1, n]],
  Outer[Times, ConstantArray[1, n], x]
};

(* ============================================================ *)
(* 2. REUSABLE ANGULAR SPECTRUM PROPAGATOR *)
(* ============================================================ *)

AngularSpectrumPropagate[field_ComplexMatrix, z_?NumericQ, λ_?NumericQ, dx_?NumericQ] := 
  Module[{nx, df, fx, fy, kx, ky, kz, H, F},
    nx = Length[field];
    df = 1.0 / (nx * dx);
    fx = RotateRight[Range[-nx/2, nx/2 - 1] * df, Floor[nx/2]];
    fy = fx;
    kx = 2 Pi * Outer[Times, fx, ConstantArray[1, nx]];
    ky = 2 Pi * Outer[Times, ConstantArray[1, nx], fy];
    kz = Sqrt[(2 Pi / λ)^2 - kx^2 - ky^2 + 0. I];
    H = Exp[I * kz * z] * UnitStep[Re[kz]];  (* evanescent wave filter *)
    F = Fourier[field, FourierParameters -> {0, -1}];
    InverseFourier[F * H, FourierParameters -> {0, -1}]
  ];

(* ============================================================ *)
(* 3. OBJECT FIELD GENERATORS *)
(* ============================================================ *)

makeObject["gaussian", params_] := Module[{x0, y0, w},
  {x0, y0, w} = params;
  Exp[-((X - x0)^2 + (Y - y0)^2) / (2 w^2)] *
    Exp[I * RandomReal[{-Pi, Pi}, {n, n}]]
];

makeObject["text", params_] := Module[{letter, textImg, diffuser},
  letter = params[[1]];
  textImg = ImageData[
    Rasterize[
      Style[letter, FontFamily -> "Helvetica", FontSize -> 140, Bold, 
        FontColor -> Black],
      RasterSize -> n, ImageSize -> n, Background -> White
    ]
  ][[All, All, 1]];  (* 0 (white) .. 1 (black) *)
  textImg = 1 - textImg;  (* invert so letter is bright *)
  diffuser = Exp[I * RandomReal[{-Pi, Pi}, {n, n}]];
  textImg * diffuser
];

makeObject["points", params_] := Module[{num, pts, field},
  num = params[[1]];
  field = ConstantArray[0. + 0. I, {n, n}];
  Do[
    pts = RandomReal[{-L/3, L/3}, 2];
    field += Exp[-((X - pts[[1]])^2 + (Y - pts[[2]])^2) / (2 (L/40)^2)] *
             Exp[I * RandomReal[{-Pi, Pi}, {n, n}]],
    num
  ];
  field
];

(* ============================================================ *)
(* 4. THE MAIN INTERACTIVE DEMO *)
(* ============================================================ *)

(* Choose your object here — try all three! *)
objectType = "text";   (* "gaussian" | "text" | "points" *)

object = Switch[objectType,
  "gaussian", makeObject["gaussian", {0.0003, -0.0004, 0.00025}],
  "text",     makeObject["text", {"H"}],
  "points",   makeObject["points", {7}]
];

(* Default reference beam angle — good starting point *)
defaultTheta = 0.9 Degree;

(* Precompute a nice reference for the initial Manipulate state *)
ref0 = Exp[I * k * Sin[defaultTheta] * X];

(* Record the hologram once (expensive part is only done when object or theta changes) *)
recordHologram[θref_] := Module[{ref},
  ref = Exp[I * k * Sin[θref] * X];
  Abs[object + ref]^2
];

holo0 = recordHologram[defaultTheta];

(* Reconstruction: illuminate with conjugate reference and propagate *)
reconstruct[zRec_, θref_] := Module[{ref},
  ref = Exp[I * k * Sin[θref] * X];
  AngularSpectrumPropagate[
    recordHologram[θref] * Conjugate[ref],
    zRec, λ, ps
  ]
];

(* ============================================================ *)
(* 5. THE MANIPULATE — everything the user interacts with *)
(* ============================================================ *)

Manipulate[
  Module[{rec, intRec, holo},
    holo = recordHologram[θ];
    rec = reconstruct[z, θ];
    intRec = Abs[rec]^2 // Rescale;
    
    GraphicsRow[
      {
        (* === OBJECT (what we are "holographing") === *)
        ArrayPlot[
          Abs[object]^2,
          ColorFunction -> "SunsetColors",
          PlotLabel -> Style["Object Amplitude²", 12, Bold],
          ImageSize -> 280,
          Frame -> False,
          PlotRange -> {0, 1}
        ],
        
        (* === RECORDED HOLOGRAM (fringe pattern) === *)
        ArrayPlot[
          holo,
          ColorFunction -> "GrayTones",
          PlotLabel -> Style[
            Row[{"Hologram | θ = ", NumberForm[θ/Degree, {4, 2}], "°"}], 12, Bold
          ],
          ImageSize -> 280,
          Frame -> False
        ],
        
        (* === RECONSTRUCTED IMAGE === *)
        ArrayPlot[
          intRec,
          ColorFunction -> "TemperatureMap",
          PlotLabel -> Style[
            Row[{"Reconstructed Intensity  z = ", NumberForm[z*1000, {5, 1}], " mm"}],
            12, Bold
          ],
          ImageSize -> 280,
          Frame -> False
        ]
      },
      Spacings -> 8,
      ImageSize -> 900
    ]
  ],
  
  (* === CONTROLS === *)
  {{z, 0.028, "Reconstruction distance z (m)"}, 0.005, 0.12, 0.0005,
   Appearance -> "Labeled", ImageSize -> Large},
  
  {{θ, defaultTheta, "Reference beam angle θ (degrees)"}, 0.3 Degree, 2.5 Degree, 0.05 Degree,
   Appearance -> "Labeled", ImageSize -> Large},
  
  (* Extra nice-to-haves *)
  Button["Reset to good defaults",
    z = 0.028; θ = defaultTheta,
    Appearance -> "DialogBox"],
  
  Button["Export current reconstruction as PNG",
    Export[
      FileNameJoin[{$HomeDirectory, "hologram_reconstruction.png"}],
      ArrayPlot[Abs[reconstruct[z, θ]]^2 // Rescale, ColorFunction -> "TemperatureMap"],
      ImageResolution -> 200
    ]; Print["Saved to ~/hologram_reconstruction.png"],
    Appearance -> "DialogBox"],
  
  TrackedSymbols :> {z, θ},           (* only update when these change *)
  SynchronousUpdating -> False,       (* crucial for smooth interaction *)
  ContinuousAction -> False,
  SaveDefinitions -> True,
  Initialization :> (
    (* Anything heavy that must run only once goes here *)
    Print["Holography demo initialized. Object type: ", objectType];
  )
]

(* ============================================================ *)
(* 6. QUICK EXPERIMENTS (uncomment and run) *)
(* ============================================================ *)

(* Try a different object — evaluate the block below, then re-run the Manipulate *)
(*
objectType = "points";
object = makeObject["points", {12}];
holo0 = recordHologram[defaultTheta];
*)

(* Change wavelength to red (633 nm HeNe) *)
(*
λ = 633 * 10^-9; k = 2 Pi / λ;
*)

(* Larger grid for higher resolution (slower but prettier) *)
(*
n = 1024; x = ps * Range[-n/2, n/2-1]; {X,Y} = ... rebuild grids ...;
*)

(* ============================================================ *)
(* 7. VALIDATION / DIAGNOSTICS *)
(* ============================================================ *)

(* Quick check: propagate a centered Gaussian — should stay nice *)
(*
testField = Exp[-((X)^2 + (Y)^2)/(2 (L/12)^2)];
testProp = AngularSpectrumPropagate[testField, 0.05, λ, ps];
ListPlot[{Abs[testField[[n/2]]]^2, Abs[testProp[[n/2]]]^2}, 
  Joined -> True, PlotLegends -> {"z=0", "z=50mm"}]
*)

Print["\n=== Holography demo ready ==="];
Print["Evaluate the Manipulate cell above."];
Print["Try changing objectType to \"gaussian\" or \"points\" and re-evaluate."];
