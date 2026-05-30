# Wolfram Skill

**Grok skill for generating high-quality Wolfram Language (Mathematica) code for physics simulations, interactive demos, and especially holography / wave optics.**

## Installation (for this project)

The skill is already present at:

```
.grok/skills/wolfram/SKILL.md
```

Grok will auto-discover it. You can invoke it with `/wolfram` or simply by asking questions that match the description (e.g. "Create a Wolfram simulation of...", "Make an interactive hologram demo in Mathematica", etc.).

## What the Skill Does Well

- **Holography & CGH** (current strength): off-axis digital holograms, kinoforms, angular spectrum propagation, interactive reconstruction, text/point-cloud objects, proper evanescent filtering, diagnostics.
- **Classical mechanics**: double pendulum, n-body, oscillators, chaos — using symplectic integrators, `ParametricNDSolveValue`, energy diagnostics.
- **Wave optics**: Gaussian beams, diffraction, interference — FFT-based methods first.
- **General interactive demo patterns**: `Manipulate` + `DynamicModule` + `Initialization` discipline, fixed `PlotRange`, performance flags, export recipes.

## Directory Layout

```
.grok/skills/wolfram/
├── SKILL.md                 # Main skill definition (lean, trigger-focused)
├── references/
│   ├── holography.md        # Detailed CGH / angular spectrum patterns & pitfalls
│   ├── mechanics.md         # ODE best practices, symplectic methods, diagnostics
│   └── wave-optics.md       # (planned) more diffraction & validation material
├── examples/
│   ├── holography-off-axis.wl   # Complete, runnable off-axis hologram demo
│   └── double-pendulum.wl       # High-quality symplectic double pendulum + diagnostics
└── scripts/                 # (future) any helper utilities
```

## Quick Start — Try These Prompts

```
/wolfram Create an interactive off-axis hologram demo with a text object

/wolfram Build a 3D point-cloud hologram simulation in Wolfram Language

/wolfram Make a beautiful double pendulum Manipulate that shows energy conservation

/wolfram Write Wolfram code for Fresnel diffraction through a circular aperture with Manipulate
```

## Philosophy

This skill encodes the hard-won lessons of writing *responsive*, *numerically trustworthy*, and *visually excellent* physics code in Wolfram Language:

- Heavy computation happens **once**, not on every frame.
- Symplectic methods and proper evanescent filtering are used by default where they matter.
- Every demo ships with diagnostics (energy error, comparison views).
- Code is copy-paste runnable and well-commented for teaching/research use.

## Contributing / Improving the Skill

1. Use the skill on real tasks.
2. Notice where it struggles or produces suboptimal code.
3. Edit `SKILL.md`, the references, or add better examples.
4. The skill will reload automatically.

## Status

- Core holography pipeline: excellent
- Mechanics patterns: strong
- More wave/FEM/PDE examples: planned
- Python/Matlab interop helpers: future

---

Built following Grok/xAI skill best practices (progressive disclosure, imperative style, concrete examples, strong trigger description).

## Repository

This is a versioned, shareable Grok skill project.

- License: [MIT](LICENSE)
- Structure: The actual skill lives in `.grok/skills/wolfram/`
- To use in another project: copy the `wolfram/` folder into that project's `.grok/skills/` directory, or symlink it.
- To develop: just edit files — Grok reloads the skill automatically on change.

### Quick development commands

```bash
# After cloning
git clone https://github.com/yourname/wolfram-skill.git
cd wolfram-skill

# Test the skill (any Grok session with this repo open will pick it up)
# Try: "Create a Wolfram Language holography simulation..."
```

Contributions, bug reports, and new high-quality examples (especially more holography or PDE/FEM cases) are very welcome.
