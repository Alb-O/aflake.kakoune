{ inputs
, lib
, system
, ...
}@pkgs:
let
  fullPkgs = inputs.nixpkgs.legacyPackages.${system};
  clipboard = import ../../../lib/clipboard.nix { pkgs = fullPkgs; };

  # Provide a Lazygit config in the store and point LG_CONFIG_FILE to it.
  config = fullPkgs.runCommand "lazygit-config" { } ''
    mkdir -p $out
    cp ${./config.yml} $out/config.yml
  '';

  # Simple launcher that delegates to upstream lazygit
  lazygitLauncher = fullPkgs.writeShellScriptBin "lazygit" ''
    exec -a "$0" "${fullPkgs.lazygit}/bin/lazygit" "$@"
  '';

  wm = inputs.wrapper-manager.lib {
    pkgs = fullPkgs;
    inherit lib;
    modules = [
      {
        wrappers.lazygit = {
          wrapperType = "shell";
          basePackage = lazygitLauncher;
          extraPackages = [
            fullPkgs.lazygit
            config
            clipboard
          ];
          env = {
            LG_CONFIG_FILE.value = "${config}/config.yml";
          };
        };
      }
    ];
  };
in
wm.config.wrappers.lazygit.wrapped
