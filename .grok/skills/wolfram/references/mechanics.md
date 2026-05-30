# Classical Mechanics & ODE Simulations in Wolfram Language

This reference covers reliable patterns for interactive physics demos using differential equations.

## Golden Rule

**Never place `NDSolve` or `ParametricNDSolveValue` calls inside the body of `Manipulate` or a frequently-updating `Dynamic`.**  
Solve once (or once per parameter family) in `Initialization :>` or outside the control, then only evaluate the resulting `InterpolatingFunction`.

## Parametric Family Pattern (Recommended)

```wolfram
sol = ParametricNDSolveValue[
  {
    m x''[t] + b x'[t] + k x[t] == 0,
    x[0] == x0, x'[0] == v0
  },
  x, {t, 0, tmax}, {m, b, k, x0, v0},
  Method -> "StiffnessSwitching"
];

Manipulate[
  Plot[sol[m, b, k, x0, v0][t], {t, 0, tmax},
    PlotRange -> {-1.1, 1.1}],
  {{tmax, 20}, 1, 100},
  {{m, 1}, 0.1, 5}, {{b, 0.1}, 0, 2}, {{k, 4}, 0.1, 20},
  {{x0, 1}, -2, 2}, {{v0, 0}, -5, 5},
  Initialization :> ( (* heavy work already done *) )
]
```

## Symplectic Integrators for Long-Term Stability

For conservative Hamiltonian systems (undamped pendulum, Kepler problem, rigid body):

```wolfram
Method -> {"SymplecticPartitionedRungeKutta", 
  "DifferenceOrder" -> 4,
  "PositionVariables" :> {θ}   (* list the position coordinates *)
}
```

Monitor total energy over time — it should stay flat within tolerance instead of drifting.

## Double Pendulum Skeleton (Lagrangian or Newton)

See the complete high-quality example in `examples/double-pendulum.wl`.

Key techniques used there:
- `ParametricNDSolveValue` with symplectic method
- Separate `DynamicModule` for running/pausing state
- Simultaneous animation + phase portrait + energy error plot
- `WhenEvent` for optional stops or resets
- `Locator` for interactive initial conditions

## n-Body Gravity

For small n (≤ 12):
- Direct `NDSolve` on the 6n first-order equations works fine.
- Use `ParametricNDSolveValue` for masses or softening length.
- For larger n, consider `NBodySimulation` (built-in, high-level) or compile the force loop.

## Collision Handling with WhenEvent

```wolfram
WhenEvent[x[t] == 0 && x'[t] < 0,
  x'[t] -> -0.9 x'[t]   (* elastic bounce with restitution *)
]
```

Multiple events, priority, and "bounce only once per crossing" logic are all supported.

## Diagnostics You Should Always Include

1. Energy (or other conserved quantity) vs time — plot the relative error.
2. Phase portrait (position vs velocity) for 1–2 DOF systems.
3. Poincaré sections for periodically driven systems.
4. Comparison against known analytic solutions on a subset of parameters.

## Performance Tips

- `MaxSteps -> 10^6` or higher for long chaotic trajectories.
- `AccuracyGoal -> 6`, `PrecisionGoal -> 6` is often enough for demos.
- Compile right-hand side with `Compile` when you have many bodies or complicated forces.
- For real-time "live" simulation (user can change force mid-run), maintain current state and re-solve only the future from the current point when parameters change.

## Common Systems & Their Gotchas

- **Damped driven pendulum / Duffing**: Stiffness when damping high → StiffnessSwitching or LSODA.
- **Kepler / central force**: Use polar coordinates or careful regularization for close approaches.
- **Rigid body (Euler equations)**: Quaternions or rotation matrices; watch for gimbal lock.
- **Chaos (Lorenz, Rössler)**: Sensitive to tolerances and integration method; use `Method -> "ExplicitRungeKutta"` with moderate order.

See `examples/double-pendulum.wl` and `examples/n-body-gravity.wl` for complete, copy-paste-ready implementations that follow all the above rules.
