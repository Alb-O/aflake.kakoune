{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, libgit2
, openssl
, sqlite
, zlib
, bash-preexec
}:

rustPlatform.buildRustPackage rec {
  pname = "intelli-shell";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "lasantosr";
    repo = "intelli-shell";
    rev = "v${version}";
    # Upstream source tarball hash (v3.1.0)
    hash = "sha256-mvvFW+YsUxL/TX/KJ5oSbXad6ZJOcxydqyN15fLlXeY=";
  };

  # Cargo vendor hash for v3.1.0
  cargoHash = "sha256-ZjfqaSbFPX7USOtcnrlny9Mqnl9mI2pddn9/5bl+OdM=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libgit2
    openssl
    sqlite
    zlib
  ];

  # Prefer system libraries over vendored copies in crates
  env = {
    OPENSSL_NO_VENDOR = true;
    LIBGIT2_NO_VENDOR = 1;
    # Enable sqlite math functions if the crate builds bundled sqlite
    LIBSQLITE3_FLAGS = "-DSQLITE_ENABLE_MATH_FUNCTIONS";
  };

  # Upstream tests currently fail to compile in nix sandbox
  doCheck = false;

  postInstall = ''
    # Install shell init snippets for easy sourcing
    initdir="$out/share/intelli-shell/init"
    mkdir -p "$initdir"

    # Bash
    cat > "$initdir/bash.sh" <<'EOS'
if [[ :$SHELLOPTS: =~ :(vi|emacs): ]]; then
  # shellcheck disable=SC1091
  source "@bash_preexec@/share/bash/bash-preexec.sh"
  eval "$("@out@"/bin/intelli-shell init bash)"
fi
EOS

    # Zsh
    cat > "$initdir/zsh.zsh" <<'EOS'
if [[ $options[zle] = on ]]; then
  eval "$("@out@"/bin/intelli-shell init zsh)"
fi
EOS

    # Fish
    cat > "$initdir/fish.fish" <<'EOS'
"@out@"/bin/intelli-shell init fish | source
if functions -q fish_user_key_bindings
  fish_user_key_bindings
end
EOS

    substituteInPlace "$initdir/bash.sh" \
      --replace "@out@" "$out" \
      --replace "@bash_preexec@" ${bash-preexec}
    substituteInPlace "$initdir/zsh.zsh" --replace "@out@" "$out"
    substituteInPlace "$initdir/fish.fish" --replace "@out@" "$out"

    # Generic profile hook users can source once (auto-detects bash/zsh)
    profiled="$out/share/profile.d"
    mkdir -p "$profiled"
    cat > "$profiled/intelli-shell.sh" <<'EOS'
#!/usr/bin/env sh
# IntelliShell profile hook — source the right init for this shell
set -eu
store_root="@out@"

# Only for interactive shells
case ''${-:-} in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

# bash
if [ -n "''${BASH_VERSION-}" ]; then
  # shellcheck disable=SC1091
  . "$store_root/share/intelli-shell/init/bash.sh"
  return 0 2>/dev/null || exit 0
fi

# zsh
if [ -n "''${ZSH_VERSION-}" ]; then
  # shellcheck disable=SC1091
  . "$store_root/share/intelli-shell/init/zsh.zsh"
  return 0 2>/dev/null || exit 0
fi

# fish must be set up in config.fish separately
exit 0
EOS
    substituteInPlace "$profiled/intelli-shell.sh" --replace "@out@" "$out"
    # Also expose in etc/profile.d for nix profile installs
    install -Dm644 "$profiled/intelli-shell.sh" "$out/etc/profile.d/intelli-shell.sh"

    # One-shot activator that appends to the user's profile files idempotently
    install -Dm755 /dev/stdin "$out/bin/intelli-shell-activate" <<'EOS'
#!/usr/bin/env bash
set -euo pipefail

store_root="@out@"

detect_shell() {
  case "''${1-}" in
    bash|zsh|fish) echo "$1"; return;;
  esac
  base=$(basename "''${SHELL-}")
  case "$base" in
    bash|zsh|fish) echo "$base";;
    *) echo bash;;
  esac
}

append_once() {
  local file line
  file="$1"; line="$2"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  if ! grep -F "$line" "$file" >/dev/null 2>&1; then
    printf '\n%s\n' "$line" >> "$file"
    echo "updated $file"
  else
    echo "already present: $file"
  fi
}

shell=$(detect_shell "''${1-}")
case "$shell" in
  bash)
    target=''${HOME}/.bashrc
    line="source \"$store_root/share/profile.d/intelli-shell.sh\""
    append_once "$target" "$line"
    ;;
  zsh)
    target=''${HOME}/.zshrc
    line="source \"$store_root/share/profile.d/intelli-shell.sh\""
    append_once "$target" "$line"
    ;;
  fish)
    target=''${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish
    line="source \"$store_root/share/intelli-shell/init/fish.fish\""
    append_once "$target" "$line"
    ;;
esac
echo "IntelliShell integration enabled for $shell. Open a new terminal."
EOS
    substituteInPlace "$out/bin/intelli-shell-activate" --replace "@out@" "$out"

    # Zsh ZDOTDIR shim to inject our init without touching user's .zshrc
    zd="$out/share/intelli-shell/zdotdir"
    mkdir -p "$zd"
    cat > "$zd/.zshrc" <<'EOS'
#!/usr/bin/env zsh
set -u
store_root="@out@"
# Load IntelliShell
source "$store_root/share/profile.d/intelli-shell.sh"
# Chain to original .zshrc if present
orig="''${ISHELL_ORIG_ZDOTDIR:-$HOME}"
if [ -r "$orig/.zshrc" ]; then
  source "$orig/.zshrc"
fi
EOS
    substituteInPlace "$zd/.zshrc" --replace "@out@" "$out"

    # Bash rc shim used with --rcfile (non-login shells)
    cat > "$out/share/intelli-shell/bash-rc.sh" <<'EOS'
#!/usr/bin/env bash
set -u
store_root="@out@"
# Load IntelliShell
source "$store_root/share/profile.d/intelli-shell.sh"
# Source system/user rc if present, to preserve environment
[ -r /etc/bashrc ] && source /etc/bashrc || true
[ -r "$HOME/.bashrc" ] && source "$HOME/.bashrc" || true
EOS
    substituteInPlace "$out/share/intelli-shell/bash-rc.sh" --replace "@out@" "$out"

    # Wrapper launchers that start a shell with integration without editing rc files
    install -Dm755 /dev/stdin "$out/bin/ishell" <<'EOS'
#!/usr/bin/env bash
set -euo pipefail
base=$(basename "''${SHELL-}")
case "''${1-}" in bash|zsh|fish) base="$1"; shift || true;; esac
case "$base" in
  bash) exec "@out@/bin/ishell-bash" "$@" ;;
  zsh)  exec "@out@/bin/ishell-zsh"  "$@" ;;
  fish) exec "@out@/bin/ishell-fish" "$@" ;;
  *)    exec "@out@/bin/ishell-bash" "$@" ;;
esac
EOS
    substituteInPlace "$out/bin/ishell" --replace "@out@" "$out"

    install -Dm755 /dev/stdin "$out/bin/ishell-bash" <<'EOS'
#!/usr/bin/env bash
exec bash --noprofile --rcfile "@out@/share/intelli-shell/bash-rc.sh" "$@"
EOS
    substituteInPlace "$out/bin/ishell-bash" --replace "@out@" "$out"

    install -Dm755 /dev/stdin "$out/bin/ishell-zsh" <<'EOS'
#!/usr/bin/env bash
export ISHELL_ORIG_ZDOTDIR="''${ZDOTDIR:-$HOME}"
export ZDOTDIR="@out@/share/intelli-shell/zdotdir"
exec zsh "$@"
EOS
    substituteInPlace "$out/bin/ishell-zsh" --replace "@out@" "$out"

    install -Dm755 /dev/stdin "$out/bin/ishell-fish" <<'EOS'
#!/usr/bin/env bash
exec fish -C "source '@out@/share/intelli-shell/init/fish.fish'" "$@"
EOS
    substituteInPlace "$out/bin/ishell-fish" --replace "@out@" "$out"
  '';

  meta = with lib; {
    description = "Like IntelliSense, but for shells";
    homepage = "https://github.com/lasantosr/intelli-shell";
    license = licenses.asl20;
    mainProgram = "intelli-shell";
    platforms = platforms.unix;
  };
}
