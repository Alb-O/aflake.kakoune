{ inputs
, lib
, system
, ...
}@pkgs:
let
  fullPkgs = inputs.nixpkgs.legacyPackages.${system};
  tools = import ../tools { inherit inputs system lib; symlinkJoin = fullPkgs.symlinkJoin; };
  
  # Provide a zk config + templates in the store
  zkConfig = fullPkgs.runCommand "zk-config" { } ''
    set -eu
    outdir="$out/share/zk"
    mkdir -p "$outdir/templates"
    install -Dm444 ${./config/config.toml} "$outdir/config.toml"
    install -Dm444 ${./templates/default.md} "$outdir/templates/default.md"
  '';

  # Simple launcher that sets sane defaults for external tools
  # and delegates to upstream zk.
  zkLauncher = fullPkgs.writeShellScriptBin "zk" ''
    set -euo pipefail

    # Seed user config directory with store-provided config if missing
    cfg_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/zk"
    mkdir -p "$cfg_dir"
    cfg_target_cfg="${zkConfig}/share/zk/config.toml"
    cfg_target_tpl="${zkConfig}/share/zk/templates"
    # Link config.toml if missing; update link if pointing to an older store path
    if [[ -L "$cfg_dir/config.toml" ]]; then
      current=$(readlink -f "$cfg_dir/config.toml" || true)
      if [[ "$current" != "$cfg_target_cfg" ]]; then
        rm -f "$cfg_dir/config.toml"
        ln -s "$cfg_target_cfg" "$cfg_dir/config.toml"
      fi
    elif [[ ! -e "$cfg_dir/config.toml" ]]; then
      ln -s "$cfg_target_cfg" "$cfg_dir/config.toml"
    fi
    # Link templates directory if missing; update if symlink target changed
    if [[ -L "$cfg_dir/templates" ]]; then
      current=$(readlink -f "$cfg_dir/templates" || true)
      if [[ "$current" != "$cfg_target_tpl" ]]; then
        rm -f "$cfg_dir/templates"
        ln -s "$cfg_target_tpl" "$cfg_dir/templates"
      fi
    elif [[ ! -e "$cfg_dir/templates" ]]; then
      ln -s "$cfg_target_tpl" "$cfg_dir/templates"
    fi

    # Ensure zk uses a real shell path on NixOS.
    # Honor ZK_SHELL if user set it; otherwise prefer $SHELL if executable,
    # else fall back to nixpkgs bash.
    if [[ -z "''${ZK_SHELL:-}" ]]; then
      if [[ -n "''${SHELL:-}" && -x "''${SHELL}" ]]; then
        export ZK_SHELL="''${SHELL}"
      else
        export ZK_SHELL="${fullPkgs.bash}/bin/bash"
      fi
    fi

    # Run upstream
    exec -a "$0" "${fullPkgs.zk}/bin/zk" "$@"
  '';

  wm = inputs.wrapper-manager.lib {
    pkgs = fullPkgs;
    inherit lib;
    modules = [
      {
        wrappers.zk = {
          wrapperType = "shell";
          basePackage = zkLauncher;
          extraPackages = [
            fullPkgs.zk
            zkConfig
            tools
          ];
          # No forced env here; launcher sets conditional defaults.
        };
      }
    ];
  };
in
wm.config.wrappers.zk.wrapped
