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

        # === Wolfram Engine 14.3 override ===
        #
        # nixpkgs' built-in wolfram-engine is still on 14.1 and uses requireFile.
        # We override src + version to point at your 14.3 installer.
        #
        # Because flakes are pure by default, we must use requireFile (not a raw /nix/store path).
        wolframEngine14_3 = pkgs.wolfram-engine.overrideAttrs (old: rec {
          version = "14.3.0";
          src = pkgs.requireFile {
            name = "WolframEngine_14.3.0_LIN.sh";
            url = "https://www.wolfram.com/engine/";
            # Replace this with the real hash (see instructions in README or run the command below)
            sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };
        });
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
              echo "  To get Wolfram Engine 14.3, run:"
              echo "    nix develop .#with-wolfram"
              echo ""
            '';
          };

          # Shell with Wolfram Engine 14.3
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
              wolframEngine14_3
            ];

            shellHook = ''
              echo ""
              echo "Wolfram Skill dev shell (Wolfram Engine 14.3)"
              echo ""

              if command -v wolframscript >/dev/null 2>&1; then
                if wolframscript -code 'Print[2+2]' >/dev/null 2>&1; then
                  echo "✓ Wolfram Engine 14.3 is activated"
                  wolframscript -version 2>/dev/null || true
                else
                  echo "⚠ Wolfram Engine is present but not activated yet."
                  echo "Run:  wolframscript   (you only need to do this once)"
                fi
              else
                echo "Wolfram Engine not found in PATH."
                echo ""
                echo "Make sure you have added the installer:"
                echo "  nix-store --add-fixed sha256 ~/Downloads/WolframEngine_14.3.0_LIN.sh"
              fi
              echo ""
            '';
          };
        };

        formatter = pkgs.alejandra;
      }
    );
}
