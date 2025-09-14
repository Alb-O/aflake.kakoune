{ pkgs,
  symlinkJoin,
  lib,
  # Category sets can be passed by caller; if absent, we'll import using full pkgs
  cli ? null,
  gui ? null,
  #intelli-shell,

  # optional overrides
  forceAll ? false,
  name ? "kakoune-flake",
  ...
}:
let
  # simple WSL detection at eval time (whether to build graphical programs)
  isWSL = (builtins.getEnv "WSL_DISTRO_NAME" != "") || (builtins.getEnv "WSL_INTEROP" != "");
  wantGraphical = forceAll || (!isWSL);
  # Ensure category attrs are populated
  cliPkgs = if cli == null then import ./cli pkgs else cli;
  guiPkgs = if gui == null then import ./gui pkgs else gui;

  pathsBase =
    # fold all CLI derivations exported under nix/packages/cli
    (builtins.attrValues cliPkgs)
    # ++ [ intelli-shell ]  # keep commented as before
  ;
in
symlinkJoin {
  name = name;
  paths = pathsBase ++ lib.optionals wantGraphical (builtins.attrValues guiPkgs);
}
