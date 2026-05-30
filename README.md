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
│   ├── quickstart.md        # 5-minute copy-paste recipes
│   ├── holography.md        # CGH, kinoforms, Gerchberg-Saxton, pitfalls
│   ├── mechanics.md         # Symplectic ODEs, energy diagnostics, chaos
│   └── wave-optics.md       # Talbot, diffraction, validation
├── examples/
│   ├── holography-off-axis.wl   # Off-axis digital hologram (recommended)
│   ├── holography-kinoform.wl   # Phase-only + iterative GS for SLMs
│   ├── talbot-effect.wl         # Near-field self-imaging (stunning)
│   ├── double-pendulum.wl       # Symplectic + live diagnostics
│   ├── lorenz-attractor.wl      # 3D chaos with parameter sliders
│   └── gaussian-beam-propagation.wl  # ASM validation test
└── scripts/                 # (future) helper utilities
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

- Holography (off-axis + kinoform/GS + Talbot): excellent and growing
- Classical mechanics + chaos: strong
- Wave optics validation patterns: solid
- More FEM/PDE and advanced CGH (full 3D, color): planned
- scripts/ helpers: next milestone

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

### Development with Nix (recommended)

This project includes a `flake.nix` with two shells:

```bash
# Basic development shell (recommended for most people)
nix develop

# Shell that also includes Wolfram Engine (see instructions below)
nix develop .#with-wolfram
```

The default shell gives you `git`, `gh`, `just`, Python + Ruff/Black, and Nix formatting tools.

#### Using Wolfram Engine 14.3

The version in nixpkgs is still 14.1. This flake uses a direct override to your already-added 14.3 installer.

1. Download `WolframEngine_14.3.0_LIN.sh` from https://www.wolfram.com/engine/.

2. Add it to your Nix store **once**:

   ```bash
   nix-store --add-fixed sha256 ~/Downloads/WolframEngine_14.3.0_LIN.sh
   ```

   (You already did this — the store path is `7qdmra8n79ddvwf6bwrgazs18j2k460w-...`.)

3. Enter the shell:

   ```bash
   nix develop .#with-wolfram
   ```

4. On first use inside the shell, activate your free license:

   ```bash
   wolframscript
   ```

After this you can run any of the examples, e.g.:

```bash
wolframscript -f .grok/skills/wolfram/examples/holography-kinoform-W.wl
```

```bash
wolframscript -f .grok/skills/wolfram/examples/holography-kinoform-W.wl
```

This two-step hash process is annoying but required because Wolfram does not allow redistribution of their installers. Once the hash is set in the flake it stays working.

Contributions, bug reports, and new high-quality examples (especially more holography or PDE/FEM cases) are very welcome.
