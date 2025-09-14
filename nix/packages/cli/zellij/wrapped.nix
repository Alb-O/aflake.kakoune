{ inputs
, lib
, system
, ...
}@pkgs:
let
  fullPkgs = inputs.nixpkgs.legacyPackages.${system};
  clipboard = import ../../../lib/clipboard.nix { pkgs = fullPkgs; };

  # Provide a Zellij config in the store and point ZELLIJ_CONFIG_DIR to it.
  config = fullPkgs.runCommand "zellij-config" { } ''
    set -eu
    outdir=$out/share/zellij
    themedir=$outdir/themes
    mkdir -p "$outdir" "$themedir"

    # Install themes
    cp ${./themes/gruvdark.kdl} "$themedir/gruvdark.kdl"

    # Install our config.kdl (includes theme and options)
    install -Dm444 ${./config.kdl} "$outdir/config.kdl"
  '';

  # Simple launcher that delegates to upstream zellij
  zellijLauncher = fullPkgs.writeShellScriptBin "zellij" ''
    exec -a "$0" "${fullPkgs.zellij}/bin/zellij" "$@"
  '';

  wm = inputs.wrapper-manager.lib {
    pkgs = fullPkgs;
    inherit lib;
    modules = [
      {
        wrappers.zellij = {
          wrapperType = "shell";
          basePackage = zellijLauncher;
          extraPackages = [
            fullPkgs.zellij
            config
            clipboard
          ];
          env = {
            ZELLIJ_CONFIG_DIR.value = "${config}/share/zellij";
          };
        };
      }
    ];
  };
in
wm.config.wrappers.zellij.wrapped
