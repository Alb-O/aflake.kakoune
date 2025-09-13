{
  inputs,
  lib,
  system,
  ...
}@pkgs:
let
  fullPkgs = inputs.nixpkgs.legacyPackages.${system};

  # Provide a Niri config in the store under share/niri
  config = fullPkgs.runCommand "niri-config" { } ''
    set -eu
    outdir=$out/share/niri
    mkdir -p "$outdir"

    # Install config.kdl
    install -Dm444 ${./config.kdl} "$outdir/config.kdl"
  '';

  # Simple launcher that delegates to upstream niri
  niriLauncher = fullPkgs.writeShellScriptBin "niri" ''
    exec -a "$0" "${fullPkgs.niri}/bin/niri" "$@"
  '';

  wm = inputs.wrapper-manager.lib {
    pkgs = fullPkgs;
    inherit lib;
    modules = [
      {
        wrappers.niri = {
          wrapperType = "shell";
          basePackage = niriLauncher;
          extraPackages = [
            fullPkgs.niri
            config
          ];
          env = {
            # Point Niri directly at the config.kdl file
            NIRI_CONFIG.value = "${config}/share/niri/config.kdl";
          };
        };
      }
    ];
  };
in
wm.config.wrappers.niri.wrapped
