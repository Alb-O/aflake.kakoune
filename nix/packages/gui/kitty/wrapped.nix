{ inputs
, lib
, system
, ...
}@pkgs:
let
  fullPkgs = inputs.nixpkgs.legacyPackages.${system};

  # Provide kitty config + theme in the store
  kittyConfig = fullPkgs.runCommand "kitty-config" { } ''
    set -eu
    outdir="$out/share/kitty"
    themedir="$outdir/themes"
    mkdir -p "$themedir"

    # Install theme
    install -Dm444 ${./gruvdark.conf} "$themedir/gruvdark.conf"

    # Install kitty.conf from the repo (kept separate from theme)
    install -Dm444 ${./kitty.conf} "$outdir/kitty.conf"
  '';

  wm = inputs.wrapper-manager.lib {
    pkgs = fullPkgs;
    inherit lib;
    modules = [
      {
        wrappers.kitty = {
          wrapperType = "shell";
          basePackage = fullPkgs.kitty;
          extraPackages = [ fullPkgs.kitty kittyConfig ];
          env = {
            # Point kitty at our bundled config directory
            KITTY_CONFIG_DIRECTORY.value = "${kittyConfig}/share/kitty";
          };
        };
      }
    ];
  };
in
wm.config.wrappers.kitty.wrapped
