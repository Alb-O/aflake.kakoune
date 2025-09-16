{
  inputs,
  lib,
  system,
  ...
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

  launcher = fullPkgs.writeShellApplication {
    name = "wezterm";
    runtimeInputs = [
      fullPkgs.wezterm
      fullPkgs.coreutils
      fullPkgs.hostname
    ];
    text = ''
      set -euo pipefail

      runtime="''${XDG_RUNTIME_DIR:-}"
      user="''${USER:-$(${fullPkgs.coreutils}/bin/id -un)}"
      host="$(${fullPkgs.hostname}/bin/hostname)"

      if [ -n "$runtime" ]; then
        socket="$runtime/wezterm-$user-$host.sock"
      else
        socket="$HOME/.wezterm-$host.sock"
      fi

      export WEZTERM_CONFIG_FILE="${weztermConfig}/share/wezterm/wezterm.lua"
      export TERMINFO_DIRS="${weztermTerminfo}/share/terminfo''${TERMINFO_DIRS:+:$TERMINFO_DIRS}"

      if [ $# -eq 0 ]; then
        if [ -S "$socket" ]; then
          export WEZTERM_UNIX_SOCKET="$socket"
          if ${fullPkgs.wezterm}/bin/wezterm cli --no-auto-start --session unix list >/dev/null 2>&1; then
            exec ${fullPkgs.wezterm}/bin/wezterm cli --no-auto-start --session unix spawn --new-window
          fi
        fi

        # Either the socket does not exist yet or the mux is unreachable;
        # signal the config to avoid trying to connect to a non-existent
        # server during GUI bootstrap so the initial launch succeeds.
        export WEZTERM_DISABLE_STARTUP_CONNECT=1
        unset WEZTERM_UNIX_SOCKET
      else
        export WEZTERM_UNIX_SOCKET="$socket"
      fi

      exec ${fullPkgs.wezterm}/bin/wezterm "$@"
    '';
  };
in
launcher
