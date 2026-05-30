# Wave Optics & Diffraction Patterns (Wolfram Language)

Short reference for common wave propagation and interference tasks beyond full holography.

## Gaussian Beam Propagation (Validation Case)

A centered Gaussian beam propagated with the Angular Spectrum method should remain approximately Gaussian (within sampling limits). This is the #1 smoke test for any ASM implementation.

See the diagnostic at the bottom of `examples/holography-off-axis.wl`.

## Single-Slit / Circular Aperture Diffraction

**Fast path (ASM):**  
Place a hard-edged aperture (or soft Gaussian) at z=0 and propagate. The far-field will approach the analytic Fourier transform of the aperture (sinc for slit, Airy for circular).

**Rigorous path (recommended for publication/validation):**  
Use the official Wolfram FEM example:

`PDEModels/tutorial/Electromagnetics/ModelCollection/SingleApertureScalarDiffraction`

It solves the Helmholtz equation with perfectly matched layers and compares against the Kirchhoff–Sommerfeld integral. Explicitly mentions holographic microscopy applications.

## Multiple Beam Interference & Young's Double Slit

Create two (or more) coherent sources as complex point-like fields, propagate the sum, and watch the fringe pattern evolve with distance. Extremely effective teaching demo.

## Talbot Effect (Self-Imaging)

Periodic amplitude or phase grating → at regular "Talbot distances" the field re-images (integer and fractional). Beautiful with `Manipulate` over z and grating period.

## Common Visualization Recipes

- Intensity: `Abs[field]^2 // Rescale`
- Phase: `Arg[field]` with `"Rainbow"` or custom cyclic map
- Complex field: `GraphicsRow[{ArrayPlot[Re@field], ArrayPlot[Im@field]}]`
- 3D wave surfaces: `ListPlot3D[Re[field], ...]` with careful downsampling

## When to Switch to FEM

- Propagation angle > ~20–25° (paraxial ASM breaks)
- Strong scattering / objects comparable to λ
- Need polarization / vector effects
- Curved surfaces or inhomogeneous media

In those cases start from the Single-Aperture tutorial and adapt the mesh + `HelmholtzPDEComponent` + `PML`.

## Performance Hierarchy (fastest → slowest)

1. Pure `Fourier`/`InverseFourier` ASM (this skill's default)
2. Fresnel single-FFT approximations
3. Direct point-source summation (spherical waves)
4. `NDSolve` / `NDSolveValue` time-domain wave equation
5. Frequency-domain FEM Helmholtz (most accurate, heaviest)

Keep ASM as your first tool for 95% of interactive demos and teaching materials.
