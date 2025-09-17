{
  inputs,
  lib,
  system,
  ...
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

  launcher = fullPkgs.writeShellApplication {
    name = "kitty";
    runtimeInputs = [
      fullPkgs.kitty
      fullPkgs.coreutils
    ];
    text = ''
      set -euo pipefail

      kitty_bin=${fullPkgs.kitty}/bin/kitty
      kitten_bin=${fullPkgs.kitty}/bin/kitten

      export KITTY_CONFIG_DIRECTORY="${kittyConfig}/share/kitty"

      user="''${USER:-$(${fullPkgs.coreutils}/bin/id -un)}"

      runtime="''${XDG_RUNTIME_DIR:-}"
      state_home="''${XDG_STATE_HOME:-$HOME/.local/state}"
      base_dir="''${KITTY_WRAPPER_STATE_DIR:-''${runtime:-$state_home}/kitty}"
      ${fullPkgs.coreutils}/bin/mkdir -p "$base_dir"

      display_raw="''${DISPLAY:-none}"
      display_tag="$(${fullPkgs.coreutils}/bin/printf '%s' "$display_raw" | ${fullPkgs.coreutils}/bin/tr '/:' '__')"

      if [ -n "''${KITTY_WRAPPER_INSTANCE_GROUP:-}" ]; then
        instance_group="''${KITTY_WRAPPER_INSTANCE_GROUP}"
      elif [ -n "''${KITTY_INSTANCE_GROUP:-}" ]; then
        instance_group="''${KITTY_INSTANCE_GROUP}"
      else
        instance_group="''${user}-''${display_tag}"
      fi

      instance_group="$(${fullPkgs.coreutils}/bin/printf '%s\n' "$instance_group" | ${fullPkgs.coreutils}/bin/tr -c '[:alnum:]_.-' '_')"

      socket_base="$base_dir/$instance_group"
      addr_file="$socket_base.addr"
      listen_socket="$base_dir/$instance_group.sock"
      listen_on="unix:$listen_socket"

      active_addr=""
      if [ -f "$addr_file" ]; then
        candidate="$(${fullPkgs.coreutils}/bin/cat "$addr_file")"
        if [ -n "$candidate" ] && "$kitten_bin" @ --to "$candidate" ls >/dev/null 2>&1; then
          active_addr="$candidate"
        else
          ${fullPkgs.coreutils}/bin/rm -f "$addr_file"
        fi
      fi

      passthrough=0
      if [ "$#" -gt 0 ]; then
        case "$1" in
          @|+*) passthrough=1 ;;
          -*) passthrough=1 ;;
        esac
      fi

      if [ "$passthrough" -eq 1 ]; then
        if [ -n "$active_addr" ]; then
          export KITTY_LISTEN_ON="$active_addr"
        fi
        exec "$kitty_bin" "$@"
      fi

      if [ -n "$active_addr" ]; then
        export KITTY_LISTEN_ON="$active_addr"
        if [ "$#" -eq 0 ]; then
          if "$kitten_bin" @ --to "$active_addr" launch --type=os-window --cwd=current >/dev/null 2>&1; then
            exit 0
          fi
        else
          if "$kitten_bin" @ --to "$active_addr" launch --cwd="$PWD" -- "$@" >/dev/null 2>&1; then
            exit 0
          fi
        fi
        ${fullPkgs.coreutils}/bin/rm -f "$addr_file"
      fi

      actual_addr="$listen_on-$$"
      ${fullPkgs.coreutils}/bin/printf '%s\n' "$actual_addr" > "$addr_file"

      export KITTY_LISTEN_ON="$actual_addr"

      exec "$kitty_bin" \
        --single-instance \
        --instance-group "$instance_group" \
        --listen-on "$listen_on" \
        -o allow_remote_control=yes \
        "$@"
    '';
  };
in
launcher
