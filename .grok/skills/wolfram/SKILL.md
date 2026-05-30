---
name: wolfram
description: This skill should be used when the user asks to create Wolfram Language code for "physics simulation", "interactive Manipulate demo", "holography simulation", "computer generated hologram", "CGH", "wave optics", "angular spectrum", "Fresnel diffraction", "double pendulum", "n-body gravity", "Lorenz attractor", or any physics visualization or demo in Mathematica/Wolfram Language.
---

# Wolfram Language Physics Simulations & Interactive Demos

Use this skill for any request involving **Wolfram Language (Mathematica)** code that simulates physical systems or creates responsive interactive demos. The language excels at symbolic + numeric wave optics, differential equations, complex fields, and high-quality visualizations.

## When to Use This Skill

- User wants working `Manipulate` or `DynamicModule` physics demos
- Holography / computer-generated holograms (CGH), digital hologram recording + reconstruction
- Classical mechanics (pendulums, orbits, n-body, rigid body)
- Wave phenomena (waves, interference, diffraction, Fourier optics)
- Chaos, oscillators, EM fields, quantum mechanics visualizations (1D/2D Schrödinger, etc.)
- Exportable animations, phase-space portraits, or publication-quality figures

## Core Principles for Good Wolfram Physics Code

**Never put heavy solvers directly inside `Manipulate` body.**  
Re-solving `NDSolve` or recomputing large FFT propagations on every slider move destroys interactivity.

**Preferred patterns (in priority order):**

1. **ParametricNDSolveValue** (or `ParametricNDSolve`) + `Initialization :>` — best for parameter sweeps in ODE/PDE systems.
2. **Precompute once** (outside Manipulate or in `Initialization`) then only evaluate the resulting `InterpolatingFunction` or array inside the control loop.
3. **Angular spectrum / FFT propagation** for all wave optics and holography (orders of magnitude faster than NDSolve for paraxial propagation).
4. **Custom fixed-step integrators** (`NestList`, `FoldList`, or `Compile`d RK4) only when you need real-time state mutation or extreme responsiveness.
5. **NDSolve FEM** (with `HelmholtzPDEComponent` + PML) only for non-paraxial diffraction or complex geometry — use for validation, not primary interactive demos.

**Always:**
- Fix `PlotRange` explicitly.
- Use `PerformanceGoal -> "Speed"` on graphics.
- Set `SynchronousUpdating -> False` and `TrackedSymbols` for smooth Manipulate.
- Use physical units consistently (m, nm, rad, etc.) and document them.
- Validate conservation laws (energy, momentum) on long runs.

## Holography & Wave Optics Workflow

Holography is one of the highest-leverage uses of Wolfram Language because of native complex numbers + fast `Fourier`.

**Standard digital holography pipeline:**

1. Define object field(s) at their plane(s) — point sources, Gaussian beams, text via `ImageData[Rasterize[...]]`, random phase diffuser.
2. (Optional) Propagate object to hologram plane using angular spectrum.
3. Add tilted reference wave → record intensity hologram `Abs[object + ref]^2`.
4. For reconstruction: multiply hologram by conjugate reference and propagate with angular spectrum to desired distance.
5. Visualize object, raw hologram fringes, reconstructed intensity + phase side-by-side.
6. Make interactive with `Manipulate` over reconstruction distance `z`, reference angle, wavelength, aperture, etc.

**Core reusable function (Angular Spectrum Propagation):**

```wolfram
ASPropagate[field_, z_, λ_, dx_] := Module[
  {n = Length[field], df, fx, fy, kx, ky, kz, H, F},
  df = 1/(n dx);
  fx = RotateRight[Range[-n/2, n/2-1] * df, n/2];
  fy = fx;
  {kx, ky} = 2 π Outer[Times, {fx, fy}[[#]], ConstantArray[1, n]] & /@ {1, 2}; (* careful transposition *)
  kz = Sqrt[(2 π/λ)^2 - kx^2 - ky^2 + 0. I];
  H = Exp[I kz z] UnitStep[Re[kz]];  (* evanescent filter *)
  F = Fourier[field, FourierParameters -> {0, -1}];
  InverseFourier[F H, FourierParameters -> {0, -1}]
];
```

**Key holography tips:**
- Off-axis (Leith-Upatnieks) holograms separate virtual/twin/zero-order images.
- Phase-only kinoforms: `Exp[I Arg[objectField]]`.
- 3D objects: sum propagated fields from multiple depth planes or point cloud.
- For rigorous non-paraxial work, fall back to the official Single-Aperture Scalar Diffraction FEM example (PDEModels tutorial).

See `references/holography.md` and `examples/holography-off-axis.nb` (or .wl) for complete working pipelines.

## Classical Mechanics & ODE Workflow

```wolfram
sol = ParametricNDSolveValue[
  {θ''[t] + b θ'[t] + Sin[θ[t]] == 0, θ[0]==θ0, θ'[0]==ω0},
  θ, {t, 0, tmax}, {b, θ0, ω0},
  Method -> {"SymplecticPartitionedRungeKutta", "DifferenceOrder"->4} (* for conservative systems *)
];

Manipulate[
  Graphics[{ ... use sol[b,θ0,ω0][t] ... }],
  {{t,0}, 0, tmax, Animator, ...},
  {{b,0.05},0,0.5}, {{θ0,π/2},0,2π}, ...
  Initialization :> ( (* nothing heavy here *))
]
```

Use symplectic integrators for long-term energy conservation in Hamiltonian systems (orbits, pendulums without strong friction).

`WhenEvent` for collisions, bounces, resets.

See `references/mechanics.md` and `examples/` for double pendulum, n-body, Lorenz, etc.

## Decision Tree

- Pure wave propagation / diffraction / CGH → **Angular spectrum (FFT)** first
- Parameterized family of ODE solutions with interactive params → **ParametricNDSolveValue**
- Need stateful real-time evolution or very fast custom stepping → **Compiled stepper or NestList**
- Complex geometry, non-paraxial, boundaries matter → **NDSolve FEM + PML** (from docs)
- Quick 1D/2D exploration → start with `NDSolve` + `Plot` then upgrade

## Visualization & Export Patterns

- Always provide at least three linked views: physical animation + phase space + diagnostic (energy error, etc.).
- Use `ArrayPlot` / `ListDensityPlot` with fixed `ColorFunction` and `PlotRange` for fields/holograms.
- `GraphicsRow` or `Grid` for clean side-by-side comparison.
- Export: `Export["demo.gif", Table[...], "AnimationRepetitions"->Infinity]`, or `Export["holo.png", ... , ImageResolution->300]`.
- For publication: `Rasterize[..., ImageResolution->300]` + careful `ImageSize`.

## Performance & Numerical Hygiene

- Grid size power of 2 for FFT (512, 1024, 2048 common).
- `SynchronousUpdating -> False` + `ContinuousAction -> False` for heavy controls.
- `MaxSteps -> Infinity` or large number in NDSolve for long simulations.
- Monitor `PrecisionGoal`/`AccuracyGoal` — relax for demos.
- For holography: zero-pad objects, careful frequency centering (`RotateRight`).
- Test evanescent filtering and aliasing on known cases (Gaussian beam propagation).

## How to Use This Skill

1. Read the relevant reference file for the domain (holography, mechanics, waves).
2. Start from the closest example in `examples/`.
3. Adapt parameters, equations, and visualization.
4. Wrap the heavy computation in `Initialization :>` or precompute outside the Manipulate.
5. Add `TrackedSymbols`, fixed ranges, and performance options.
6. Provide the user both a complete notebook-style cell group **and** a clean `.wl` script version when possible.

## Additional Resources

### Reference Files
- `references/holography.md` — Full CGH pipeline, kinoforms, 3D objects, common pitfalls
- `references/mechanics.md` — Symplectic methods, n-body, WhenEvent patterns, energy diagnostics
- `references/wave-optics.md` — Angular spectrum variants, Fresnel/Fraunhofer, validation against analytics
- `references/performance.md` — Compilation, memoization, grid sizing, parallel tips

### Complete Examples
- `examples/holography-off-axis.wl` — Off-axis digital hologram recording + interactive reconstruction (recommended starting point)
- `examples/double-pendulum.wl` — Classic high-quality Manipulate with symplectic integration and phase portrait
- `examples/gaussian-beam-propagation.wl` — Wave optics validation case
- `examples/n-body-gravity.wl` — Simple gravitational n-body with Manipulate

Copy these directly into a Wolfram notebook or `.wl` file. They are designed to be immediately runnable and modifiable.

**Always validate** that energy/momentum is reasonably conserved and that the hologram reconstructs at the expected distance before delivering to the user.

This skill keeps Wolfram Language physics work fast, correct, and beautiful.
