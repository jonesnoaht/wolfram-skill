# Holography & Wave Optics in Wolfram Language

This reference contains battle-tested patterns for computer-generated holography (CGH), digital hologram simulation, reconstruction, and general scalar wave optics using the Angular Spectrum Method (ASM) and related techniques.

## Core Concepts

**Digital Holography Pipeline (Leith-Upatnieks / off-axis):**
1. Object wave O(x,y) at hologram plane (complex amplitude).
2. Reference wave R(x,y) — usually a tilted plane wave.
3. Recorded intensity hologram: H = |O + R|².
4. Reconstruction: illuminate with R* (conjugate) → propagate to image plane(s).
5. Virtual image (desired), twin image (conjugate), and zero-order (DC) terms separate spatially when carrier frequency is high enough.

**Angular Spectrum Propagation (preferred method):**
Fast, exact within scalar paraxial + uniform medium assumptions. One forward + one inverse FFT per propagation step.

**When to use what:**
- **ASM (FFT)**: Most CGH, Fresnel/Fraunhofer propagation, quick interactive demos. n = 512–2048 typical.
- **Fresnel approximation** (quadratic phase): Sometimes simpler single-FFT form for far-field.
- **NDSolve FEM + Helmholtz + PML**: Non-paraxial, complex apertures, vector effects, rigorous validation against analytics (see official Single-Aperture Scalar Diffraction tutorial). Much slower.
- **Point source summation / spherical waves**: Simple 3D point-cloud holograms (slow for many points; use ASM layered instead).

## Production-Grade Angular Spectrum Propagator

```wolfram
ClearAll[AngularSpectrumPropagate];

AngularSpectrumPropagate[field_ComplexMatrix, z_?NumericQ, λ_?NumericQ, dx_?NumericQ] := 
  Module[{n, df, fx, fy, kx, ky, kz, H, F},
    n = Length[field];
    df = 1/(n dx);
    fx = RotateRight[Range[-n/2, n/2 - 1] df, Floor[n/2]];
    fy = fx;
    kx = 2 π Outer[Times, fx, ConstantArray[1, n]];
    ky = 2 π Outer[Times, ConstantArray[1, n], fy];  (* correct transposition *)
    kz = Sqrt[(2 π/λ)^2 - kx^2 - ky^2 + 0. I];
    H = Exp[I kz z] * UnitStep[Re[kz]];  (* hard cutoff for evanescent waves *)
    F = Fourier[field, FourierParameters -> {0, -1}];
    InverseFourier[F * H, FourierParameters -> {0, -1}]
  ];
```

**Important details:**
- `RotateRight[..., Floor[n/2]]` centers the zero frequency (critical).
- `UnitStep[Re[kz]]` removes evanescent components (|k_perp| > k) that would otherwise explode or alias.
- For very large |z| or fine features, increase n and/or zero-pad the input field.
- Test scaling on a known case: on-axis Gaussian beam should remain Gaussian (within sampling).

**Fresnel single-FFT form (alternative for large z):**
Useful when the quadratic phase approximation holds. See wave-optics.md for variants.

## Object Field Generation Recipes

### 1. Simple point or Gaussian "star"
```wolfram
object = Exp[-((X - x0)^2 + (Y - y0)^2)/(2 w^2)] * Exp[I RandomReal[{-π, π}, {n, n}]];
```

### 2. Text or binary amplitude object (excellent for demos)
```wolfram
textImg = ImageData[Rasterize[
  Style["W", FontFamily -> "Helvetica", FontSize -> 120, Bold],
  RasterSize -> n, ImageSize -> n
]][[All, All, 1]];  (* 0..1 grayscale *)
object = textImg * Exp[I RandomReal[{-π, π}, {n, n}]];  (* random phase diffuser *)
```

### 3. Multiple depth planes (layered 3D)
Propagate each layer to the hologram plane with its own z, sum the complex fields.

### 4. Random phase diffuser (reduces speckle visibility in reconstruction)
Always multiply amplitude objects by `Exp[I RandomReal[{-π, π}, dims]]` unless you specifically want coherent artifacts.

## Complete Off-Axis Hologram Recording + Reconstruction

See `examples/holography-off-axis.wl` for the full interactive version. Core logic:

```wolfram
(* 1. Geometry *)
λ = 532 10^-9; ps = 5 10^-6; n = 512; L = n ps;
k = 2 π/λ;
x = ps Range[-n/2, n/2-1];
{X, Y} = {Outer[Times, x, ConstantArray[1,n]], Outer[Times, ConstantArray[1,n], x]};

(* 2. Object at z=0 *)
object = ... (* from recipes above *);

(* 3. Tilted reference *)
θref = 0.8 Degree;
ref = Exp[I k Sin[θref] X];

(* 4. Hologram *)
holo = Abs[object + ref]^2;

(* 5. Reconstruction kernel (use conjugate ref) *)
reconstruct[zRec_] := AngularSpectrumPropagate[holo * Conjugate[ref], zRec, λ, ps];

(* 6. Visualize *)
Manipulate[
  rec = reconstruct[z];
  GraphicsRow[{
    ArrayPlot[Abs[object]^2, ...],
    ArrayPlot[holo, ColorFunction->"GrayTones", ...],
    ArrayPlot[Abs[rec]^2 // Rescale, ...]
  }],
  {{z, 0.03, "Reconstruction distance"}, 0.005, 0.15, 0.0005}
]
```

**Tuning the carrier:**
- Increase `θref` to separate orders more (but watch sampling: max fringe frequency < 1/(2 ps)).
- Typical good range for n=512, ps=5–8 µm, λ=532 nm: 0.5–2.0°.

## Variants

**In-line (Gabor) holography** — reference and object collinear. Simpler setup, but severe twin-image overlap. Reconstruction distance signs matter.

**Phase-only kinoform** (most common for SLM display):
```wolfram
kinoform = Exp[I Arg[objectFieldAtHolo]];
```
Reconstruct by illuminating with plane wave and propagating. No DC or twin if you iterate (Gerchberg-Saxton).

**Iterative CGH algorithms** (Gerchberg-Saxton, etc.) — implement as a `FixedPoint` or `Do` loop with Fourier constraints in object and hologram planes. Excellent student project.

**Color holography** — run three independent channels (R/G/B) with different λ and combine `Image` or `ColorCombine`.

**Holographic interferometry** — record two states, subtract phases or intensities after reconstruction. Extremely powerful with WL's `Arg` and `ListContourPlot`.

## Common Pitfalls & Fixes

| Symptom                        | Likely Cause                          | Fix |
|--------------------------------|---------------------------------------|-----|
| Reconstruction looks like noise | Frequency grid not centered, or evanescent blow-up | Fix RotateRight + UnitStep[Re[kz]] |
| Image appears at wrong z       | Sign error in propagation direction or reference conjugation | Try negative z or flip Conjugate |
| Strong DC / zero-order spot    | No or too-small reference tilt        | Increase θref carefully |
| Speckle / poor contrast        | No random phase diffuser on object    | Add random phase |
| Fringes alias / not resolved   | Carrier frequency > Nyquist           | Reduce θref or increase n/ps |
| Energy not conserved on propagation | Numerical dispersion or missing padding | Zero-pad + test on Gaussian |

## Validation Checklist (always do this)

1. Free-space propagation of a centered Gaussian beam should stay approximately Gaussian (check with `ListPlot` of central row).
2. A point source at known (x0,y0,z0) should reconstruct sharply at the correct zRec.
3. Total power (sum of intensity) should be roughly constant vs z (within sampling/aliasing limits).
4. Hologram fringe period matches  λ / sin(θref) analytically.

## FEM Alternative (Rigorous, Slow)

When ASM assumptions break (large angles, complex 3D scatterers, vector polarization):

Use the official Wolfram tutorial:
- `PDEModels/tutorial/Electromagnetics/ModelCollection/SingleApertureScalarDiffraction`
- `HelmholtzPDEComponent`, `PDEModeling` boundary conditions, perfectly matched layers (PML).
- Excellent for holographic microscopy modeling and validation of ASM results.

## Performance Notes

- n=512: instant on modern hardware.
- n=1024–2048: still very usable for demos (a few seconds for recording + reconstruction).
- Memoize propagators when z is fixed: `prop[z_] := prop[z] = ...`.
- For real-time SLM preview, precompute kernels or use GPU via `CUDALink` / `OpenCLLink` (advanced).

## Further Reading (inside WL)

- `?Fourier*` documentation
- `PDEModels/tutorial/Electromagnetics/ModelCollection/SingleApertureScalarDiffraction`
- Wolfram Community notebooks on vectorial diffraction integrals (search "angular spectrum" + "González-Acuña")
- "Introduction to Fourier Optics" (Goodman) — translate the math directly; WL makes it executable.

This reference + `examples/holography-off-axis.wl` + `examples/holography-kinoform.wl` should let you generate production-quality, immediately runnable holography simulations and teaching demos (including phase-only SLM work) in minutes.
