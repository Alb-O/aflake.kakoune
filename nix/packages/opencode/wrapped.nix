{ callPackage, models-dev, opencode-config, inputs, lib, system, ... }@pkgs:
let
  # Get the full nixpkgs with all functions
  fullPkgs = inputs.nixpkgs.legacyPackages.${system};
  # Shared LSP packages from this flake
  lspPkgs = import ../../lib/lsp.nix { pkgs = fullPkgs; };
  # Shared formatter packages from this flake
  fmtPkgs = import ../../lib/formatters.nix { pkgs = fullPkgs; };
  # Shared clipboard wrapper
  clipboard = import ../../lib/clipboard.nix { pkgs = fullPkgs; };
  # Build the base opencode package
  opencode-base = callPackage ../opencode-git.nix {
    inherit models-dev;
  };

  # Create wrapper-manager evaluation
  wm-eval = inputs.wrapper-manager.lib {
    pkgs = fullPkgs;
    inherit lib;
    modules = [
      {
        wrappers.opencode = {
          basePackage = opencode-base;
          # Override XDG_CONFIG_HOME to point to our bundled config
          env = {
            XDG_CONFIG_HOME = {
              value = "${opencode-config}";
              force = true;
            };
          };
          # Share LSP + formatter packages to match devShell and other wrappers
          extraPackages = lspPkgs ++ fmtPkgs ++ [ clipboard ];
        };
      }
    ];
  };
in
wm-eval.config.wrappers.opencode.wrapped
