# Justfile for the Wolfram Skill project
# https://github.com/casey/just
#
# Install just:
#   - macOS: brew install just
#   - NixOS: nix profile install nixpkgs#just
#   - Other: https://github.com/casey/just#installation

# Show available commands
default:
    @just --list

# === Wolfram Examples (run via wolframscript) ===

# Kinoform of the letter "W" — exports phase pattern + reconstruction images
kinoform-w:
    @echo "→ Running kinoform of letter W (exports images)..."
    wolframscript -f .grok/skills/wolfram/examples/holography-kinoform-W.wl

# Off-axis digital hologram demo
offaxis:
    @echo "→ Running off-axis hologram demo..."
    wolframscript -f .grok/skills/wolfram/examples/holography-off-axis.wl

# Talbot self-imaging effect (very pretty)
talbot:
    @echo "→ Running Talbot effect demo..."
    wolframscript -f .grok/skills/wolfram/examples/talbot-effect.wl

# Generic kinoform example (SLM version)
kinoform:
    @echo "→ Running generic kinoform demo..."
    wolframscript -f .grok/skills/wolfram/examples/holography-kinoform.wl

# Double pendulum with energy diagnostics
pendulum:
    @echo "→ Running double pendulum simulation..."
    wolframscript -f .grok/skills/wolfram/examples/double-pendulum.wl

# Lorenz attractor (chaos)
lorenz:
    @echo "→ Running Lorenz attractor..."
    wolframscript -f .grok/skills/wolfram/examples/lorenz-attractor.wl

# === Development helpers ===

# Enter the full development shell with Wolfram Engine
shell:
    nix develop .#with-wolfram

# Enter the basic shell (no Wolfram)
shell-basic:
    nix develop

# Show all available Wolfram examples
list-examples:
    @echo "Available examples you can run with 'just <name>':"
    @just --summary | grep -E '^[a-z]' | cat
