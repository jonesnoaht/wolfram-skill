(* ::Package:: *)

(*
   LORENZ ATTRACTOR — CLASSIC CHAOS DEMO
   
   3D butterfly with live parameter control and projection views.
   Uses NDSolve with StiffnessSwitching for robustness across parameter space.
*)

ClearAll["Global`*"];

lorenzEqns = {
  x'[t] == σ (y[t] - x[t]),
  y'[t] == x[t] (ρ - z[t]) - y[t],
  z'[t] == x[t] y[t] - β z[t],
  x[0] == x0, y[0] == y0, z[0] == z0
};

(* Parametric solver *)
lorenzSol = ParametricNDSolveValue[
  lorenzEqns,
  {x, y, z},
  {t, 0, tmax},
  {σ, ρ, β, x0, y0, z0},
  Method -> "StiffnessSwitching",
  MaxSteps -> 10^6
];

Manipulate[
  {xs, ys, zs} = lorenzSol[σ, ρ, β, x0, y0, z0];
  
  GraphicsRow[
    {
      (* 3D attractor *)
      ParametricPlot3D[
        {xs[t], ys[t], zs[t]},
        {t, 0, tmax},
        PlotRange -> All,
        ColorFunction -> (Hue[#4/1.2] &),
        ImageSize -> 320,
        PlotLabel -> Style["Lorenz Attractor (3D)", 12, Bold],
        Boxed -> True,
        AxesLabel -> {"x", "y", "z"}
      ],
      
      (* xy projection + time series *)
      Column[
        {
          ParametricPlot[
            {xs[t], ys[t]},
            {t, 0, tmax},
            PlotRange -> All,
            ImageSize -> 260,
            PlotLabel -> "xy projection",
            Frame -> True
          ],
          Plot[
            {xs[t], ys[t], zs[t]},
            {t, 0, tmax},
            PlotRange -> All,
            ImageSize -> 260,
            PlotLegends -> {"x", "y", "z"},
            PlotLabel -> "Time series"
          ]
        },
        Spacings -> 4
      ]
    },
    Spacings -> 10
  ],
  
  (* Classic chaotic parameters *)
  {{σ, 10, "σ"}, 5, 20, 0.1, Appearance -> "Labeled"},
  {{ρ, 28, "ρ (Rayleigh number)"}, 10, 50, 0.5, Appearance -> "Labeled"},
  {{β, 8/3, "β"}, 1, 5, 0.05, Appearance -> "Labeled"},
  
  {{tmax, 40, "Integration time"}, 5, 100, 1, Appearance -> "Labeled"},
  
  {{x0, 0.1, "x(0)"}, -20, 20, 0.1},
  {{y0, 0, "y(0)"}, -20, 20, 0.1},
  {{z0, 20, "z(0)"}, 0, 40, 0.1},
  
  SynchronousUpdating -> False,
  ContinuousAction -> False,
  TrackedSymbols :> {σ, ρ, β, tmax, x0, y0, z0}
]

(* Experiments to try:
   - ρ ≈ 24.06 : transition to chaos
   - ρ = 28 (classic)
   - Very large ρ : different regime
   - Tiny change in initial conditions → completely different long-term path (butterfly effect)
*)
