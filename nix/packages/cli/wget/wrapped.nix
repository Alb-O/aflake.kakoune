{ inputs
, lib
, system
, ...
}:
let
  fullPkgs = inputs.nixpkgs.legacyPackages.${system};

  # Simple launcher that delegates to upstream wget with HSTS file configuration
  wgetLauncher = fullPkgs.writeShellScriptBin "wget" ''
    data_home="''${XDG_DATA_HOME:-$HOME/.local/share}"
    exec -a "$0" "${fullPkgs.wget}/bin/wget" --hsts-file="$data_home/wget-hsts" "$@"
  '';

  wm = inputs.wrapper-manager.lib {
    pkgs = fullPkgs;
    inherit lib;
    modules = [
      {
        wrappers.wget = {
          wrapperType = "shell";
          basePackage = wgetLauncher;
          extraPackages = [
            fullPkgs.wget
          ];
        };
      }
    ];
  };
in
wm.config.wrappers.wget.wrapped