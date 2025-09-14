{ inputs, system, lib, ... }@pkgs:
let
  fullPkgs = inputs.nixpkgs.legacyPackages.${system};
  env = import ../../../lib/env.nix { pkgs = fullPkgs; };

  bashProfile = fullPkgs.writeText "kakkle-env.sh" ''
    # kakkle environment
    export EDITOR='${env.EDITOR}'
    export VISUAL='${env.VISUAL}'
    export TERMINAL='${env.TERMINAL}'
  '';
in
fullPkgs.runCommand "kakkle-env" { } ''
  set -eu
  install -Dm644 ${bashProfile} "$out/share/profile.d/kakkle-env.sh"
  # Also expose under etc/ for auto-loading via nix profile on some setups
  install -Dm644 ${bashProfile} "$out/etc/profile.d/kakkle-env.sh"
''
