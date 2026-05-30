# 5-Minute Quick Start — Wolfram Physics & Holography Demos

Copy one of these blocks into a new Wolfram notebook or `.wl` file and evaluate.

## 1. Holography (Off-Axis Digital Hologram)

```wolfram
(* Paste the entire contents of examples/holography-off-axis.wl here *)
(* Then evaluate — play with the Manipulate *)
```

**Fast variant:** Change `objectType = "text"` to `"gaussian"` or `"points"` and re-evaluate the object + holo lines.

## 2. Phase-Only Kinoform (for SLMs)

```wolfram
(* Paste examples/holography-kinoform.wl *)
(* Toggle the "Use iterative" checkbox to see Gerchberg-Saxton improvement *)
```

## 3. Classic Double Pendulum (with energy diagnostic)

```wolfram
(* Paste examples/double-pendulum.wl *)
(* Try chaotic initial conditions: θ1(0) ≈ 2.9, θ2(0) ≈ 0.7 *)
```

## 4. Talbot Self-Imaging (pure wave optics beauty)

```wolfram
(* Paste examples/talbot-effect.wl *)
(* Jump to z = z_T to see perfect self-image *)
```

## 5. Lorenz Attractor (chaos)

```wolfram
(* Paste examples/lorenz-attractor.wl *)
(* Watch the butterfly when you slightly change initial conditions *)
```

## 6. Gaussian Beam Validation (test your propagator)

```wolfram
(* Paste examples/gaussian-beam-propagation.wl *)
(* The central slice must stay Gaussian — this catches most ASM bugs *)
```

## Golden Rules (memorize these)

1. **Heavy solvers live in `Initialization :>` or outside `Manipulate`**
2. **Always fix `PlotRange`**
3. **Use symplectic methods for long conservative simulations**
4. **For wave optics: Angular Spectrum (FFT) first, FEM only when you truly need it**
5. **Ship diagnostics** (energy error, comparison plots, known analytic cases)

## Common First Customizations

- Change wavelength / pixel pitch / grid size (`n`)
- Swap the object generator (text → your own logo via `Rasterize`)
- Add a second reconstruction view (phase + intensity)
- Export: `Export["demo.gif", Table[ ... graphics ... ], "AnimationRepetitions" -> Infinity]`

You now have production-quality starting points for 90% of physics + holography teaching/research demos.
