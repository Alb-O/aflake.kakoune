{ inputs, lib, system, ... }@pkgs:
let
  fullPkgs = inputs.nixpkgs.legacyPackages.${system};

  # Provide an Atuin config in the store and point XDG_CONFIG_HOME to it.
  config = fullPkgs.runCommand "atuin-config" { } ''
    set -eu
    mkdir -p "$out/atuin"
    cat > "$out/atuin/config.toml" <<'EOF'
auto_sync = true
search_mode = "fuzzy"
sync_address = "https://api.atuin.sh"
sync_frequency = "5m"
EOF
  '';

  # Launcher that delegates to upstream atuin
  atuinLauncher = fullPkgs.writeShellScriptBin "atuin" ''
    exec -a "$0" "${fullPkgs.atuin}/bin/atuin" "$@"
  '';

  wm = inputs.wrapper-manager.lib {
    pkgs = fullPkgs;
    inherit lib;
    modules = [
      {
        wrappers.atuin = {
          wrapperType = "shell";
          basePackage = atuinLauncher;
          extraPackages = [ fullPkgs.atuin config ];
          env = {
            XDG_CONFIG_HOME.value = "${config}";
          };
        };
      }
    ];
  };
in
wm.config.wrappers.atuin.wrapped

