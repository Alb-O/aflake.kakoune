{ inputs
, system
, lib
, ...
}@pkgs:
let
  fullPkgs = inputs.nixpkgs.legacyPackages.${system};
  selectedPlugins = [
    "smart-enter.yazi"
    "git.yazi"
    "smart-filter.yazi"
  ];

  pluginSource = fullPkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "d1c8baab86100afb708694d22b13901b9f9baf00";
    hash = "sha256-52Zn6OSSsuNNAeqqZidjOvfCSB7qPqUeizYq/gO+UbE=";
  };

  config = fullPkgs.runCommand "yazi-config" { } ''
    set -eu
    outdir=$out/share/yazi
    plugdir=$outdir/plugins
    mkdir -p "$outdir" "$plugdir"

    install -Dm444 ${./keymap.toml} "$outdir/keymap.toml"
    install -Dm444 ${./yazi.toml} "$outdir/yazi.toml"
    install -Dm444 ${./init.lua} "$outdir/init.lua"

    for plugin in ${lib.concatStringsSep " " selectedPlugins}; do
      cp -R ${pluginSource}/$plugin "$plugdir/$plugin"
    done
  '';

  yaziLauncher = fullPkgs.writeShellScriptBin "yazi" ''
    export YAZI_CONFIG_HOME="${config}/share/yazi"
    exec -a "$0" "${fullPkgs.yazi}/bin/yazi" "$@"
  '';

  yaLauncher = fullPkgs.writeShellScriptBin "ya" ''
    export YAZI_CONFIG_HOME="${config}/share/yazi"
    exec -a "$0" "${fullPkgs.yazi}/bin/ya" "$@"
  '';
in
fullPkgs.runCommand "yazi" { } ''
  set -eu
  mkdir -p $out/bin

  install -Dm755 ${yaziLauncher}/bin/yazi $out/bin/yazi
  install -Dm755 ${yaLauncher}/bin/ya $out/bin/ya

  ln -s ${fullPkgs.yazi}/share $out/share
''
