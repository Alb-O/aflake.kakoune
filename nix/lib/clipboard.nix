{ pkgs }:
let
  wl = pkgs.wl-clipboard;
  copy = pkgs.writeShellApplication {
    name = "wl-copy";
    runtimeInputs = [ wl pkgs.coreutils pkgs.gnugrep ];
    text = ''
      set -euo pipefail
      if "${wl}/bin/wl-copy" "$@"; then
        exit 0
      fi

      # Fallback to clip.exe (WSL/Windows) if available
      fallback() {
        if command -v clip.exe >/dev/null 2>&1; then
          if [ ! -t 0 ]; then
            # Data is coming from stdin (preferred when present)
            exec clip.exe
          else
            # No stdin; try first non-flag arg as payload
            for arg in "$@"; do
              case "$arg" in
                -*) ;; # skip flags like -n
                *) printf "%s" "$arg" | exec clip.exe ;;
              esac
            done
            # Nothing to copy
            exit 1
          fi
        elif [ -x /mnt/c/Windows/System32/clip.exe ]; then
          if [ ! -t 0 ]; then
            exec /mnt/c/Windows/System32/clip.exe
          else
            for arg in "$@"; do
              case "$arg" in
                -*) ;;
                *) printf "%s" "$arg" | exec /mnt/c/Windows/System32/clip.exe ;;
              esac
            done
            exit 1
          fi
        else
          echo "wl-copy failed and clip.exe not available" >&2
          exit 1
        fi
      }

      fallback "$@"
    '';
  };

  paste = pkgs.writeShellApplication {
    name = "wl-paste";
    runtimeInputs = [ wl ];
    text = ''
      exec "${wl}/bin/wl-paste" "$@"
    '';
  };
in
pkgs.symlinkJoin {
  name = "clipboard-tools";
  paths = [ copy paste ];
}

