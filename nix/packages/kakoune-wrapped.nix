{
  inputs,
  lib,
  system,
  ...
}@pkgs:
let
  # Use full nixpkgs for wrapper-manager eval
  fullPkgs = inputs.nixpkgs.legacyPackages.${system};

  # Create a package containing the kakrc config
  config = fullPkgs.runCommand "kakoune-config" {} ''
    mkdir -p $out/share/kak
    cp ${./kakrc} $out/share/kak/kakrc
  '';

  # A tiny launcher for kakoune
  kakouneLauncher = fullPkgs.writeShellScriptBin "kakoune" ''
    exec -a "$0" "${fullPkgs.kakoune}/bin/kak" "$@"
  '';

  wm = inputs.wrapper-manager.lib {
    pkgs = fullPkgs;
    inherit lib;
    modules = [
      {
        wrappers.kakoune = {
          # Use shell wrappers for all binaries in this bundle
          wrapperType = "shell";
          # Use our custom launcher as the primary binary, but also ship upstream
          basePackage = kakouneLauncher;
          extraPackages = [ fullPkgs.kakoune config ];

          # Set environment variables for kakoune
          env = {
            XDG_CONFIG_HOME.value = "${config}/share";
          };
        };
      }
    ];
  };
in
wm.config.wrappers.kakoune.wrapped
