{ inputs
, system
, ...
}:
let
  fullPkgs = inputs.nixpkgs.legacyPackages.${system};
in
fullPkgs.runCommand "xdg-terminal" { } ''
    set -eu
    mkdir -p "$out/bin"
    cat > "$out/bin/xdg-terminal" <<'EOS'
  #!/usr/bin/env bash
  set -euo pipefail

  term="''${TERMINAL:-}"
  if [[ -n "$term" ]]; then
    exec "$term" "$@"
  fi

  for cmd in kitty wezterm alacritty foot gnome-terminal konsole xterm; do
    if command -v "$cmd" >/dev/null 2>&1; then
      exec "$cmd" "$@"
    fi
  done

  echo "xdg-terminal: no terminal emulator found (set \$TERMINAL)" >&2
  exit 1
  EOS
    chmod +x "$out/bin/xdg-terminal"
    ln -s xdg-terminal "$out/bin/x-terminal-emulator"
''
