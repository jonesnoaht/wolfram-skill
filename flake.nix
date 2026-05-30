{
  description = "Wolfram Language skill for Grok — high-quality physics simulations, interactive demos, and holography (including kinoforms and CGH)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true; # Required for wolfram-engine and mathematica
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Version control & GitHub
            git
            gh

            # Task runner (highly recommended)
            just

            # Python (useful for future scripts/ and general tooling)
            python3
            python3Packages.pip
            python3Packages.ruff
            python3Packages.black

            # Nix tooling
            alejandra
            statix
            deadnix

            # Wolfram Language (free Wolfram Engine)
            wolfram-engine
          ];

          shellHook = ''
            echo ""
            echo "╔════════════════════════════════════════════════════════════╗"
            echo "║   Wolfram Skill Development Environment                    ║"
            echo "╚════════════════════════════════════════════════════════════╝"
            echo ""
            echo "  Project: wolfram-skill (physics + holography demos)"
            echo ""

            # Check Wolfram Engine status
            if command -v wolframscript >/dev/null 2>&1; then
              if wolframscript -code 'Print[1+1]' >/dev/null 2>&1; then
                echo "  ✓ Wolfram Engine is activated and working"
                echo "    Version: $(wolframscript -version 2>/dev/null || echo 'unknown')"
              else
                echo "  ⚠ Wolfram Engine is installed but not yet activated"
                echo "    Run:  wolframscript"
                echo "    (You'll need a free license from https://www.wolfram.com/engine/)"
              fi
            else
              echo "  ✗ wolframscript not found in PATH"
            fi

            echo ""
            echo "  Useful commands:"
            echo "    just --list          # if you add a justfile later"
            echo "    nix fmt              # format this flake"
            echo ""
            echo "  To run examples:"
            echo "    wolframscript -f .grok/skills/wolfram/examples/holography-kinoform-W.wl"
            echo ""
          '';
        };

        # Formatter for `nix fmt`
        formatter = pkgs.alejandra;
      }
    );
}
