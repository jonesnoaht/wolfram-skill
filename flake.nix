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
          config.allowUnfree = true;
        };

        # Wolfram Engine is special: the nixpkgs derivation does NOT download
        # the installer for you. You must manually download it once and add it
        # to the store. See the shellHook and README for instructions.
        wolframPackages = with pkgs; [
          wolfram-engine
        ];
      in
      {
        devShells = {
          # Main development shell (recommended for most people)
          default = pkgs.mkShell {
            packages = with pkgs; [
              git
              gh
              just

              # Python tooling (useful for future scripts/)
              python3
              python3Packages.pip
              python3Packages.ruff
              python3Packages.black

              # Nix development tools
              alejandra
              statix
              deadnix
            ];

            shellHook = ''
              echo ""
              echo "╔════════════════════════════════════════════════════════════╗"
              echo "║   Wolfram Skill Development Environment                    ║"
              echo "╚════════════════════════════════════════════════════════════╝"
              echo ""
              echo "  Tools available: git, gh, just, python3, ruff, alejandra, statix"
              echo ""
              echo "  To also get Wolfram Engine in your shell, run:"
              echo "    nix develop .#with-wolfram"
              echo ""
              echo "  Or manually add it later (see instructions below)."
              echo ""
            '';
          };

          # Optional shell that includes Wolfram Engine.
          # This will fail on first use until you manually add the installer.
          with-wolfram = pkgs.mkShell {
            packages = with pkgs; [
              git
              gh
              just
              python3
              python3Packages.pip
              python3Packages.ruff
              python3Packages.black
              alejandra
              statix
              deadnix
              wolfram-engine
            ];

            shellHook = ''
              echo ""
              echo "Wolfram Skill dev shell (with Wolfram Engine)"
              echo ""

              if command -v wolframscript >/dev/null 2>&1; then
                if wolframscript -code 'Print[2+2]' >/dev/null 2>&1; then
                  echo "✓ Wolfram Engine is installed and activated"
                  wolframscript -version 2>/dev/null || true
                else
                  echo "⚠ Wolfram Engine package is present but not activated yet."
                  echo ""
                  echo "Run this to activate it (free license):"
                  echo "  wolframscript"
                  echo ""
                  echo "You only need to do this once."
                fi
              else
                echo "Wolfram Engine is not in this environment."
              fi
              echo ""
            '';
          };
        };

        formatter = pkgs.alejandra;
      }
    );
}
