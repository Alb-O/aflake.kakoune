{ inputs
, lib
, system
, ...
}@pkgs:
let
  fullPkgs = inputs.nixpkgs.legacyPackages.${system};

  # Provide wezterm config in the store
  weztermConfig = fullPkgs.runCommand "wezterm-config" { } ''
    set -eu
    outdir="$out/share/wezterm"
    mkdir -p "$outdir"
    # Install wezterm.lua from the repo
    install -Dm444 ${./wezterm.lua} "$outdir/wezterm.lua"
  '';

  # Provide wezterm terminfo in the store
  weztermTerminfo = import ./terminfo.nix { inherit inputs lib system; };

  wm = inputs.wrapper-manager.lib {
    pkgs = fullPkgs;
    inherit lib;
    modules = [
      {
        wrappers.wezterm = {
          wrapperType = "shell";
          basePackage = fullPkgs.wezterm;
          extraPackages = [
            fullPkgs.wezterm
            weztermConfig
            weztermTerminfo
          ];
          env = {
            # Point WezTerm at our bundled config file
            WEZTERM_CONFIG_FILE.value = "${weztermConfig}/share/wezterm/wezterm.lua";
            # Set TERMINFO_DIRS for proper terminfo detection
            TERMINFO_DIRS.value = "${weztermTerminfo}/share/terminfo";
          };
        };
      }
    ];
  };
in
wm.config.wrappers.wezterm.wrapped
