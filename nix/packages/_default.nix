{
  symlinkJoin,
  lib,
  kakoune,
  zellij,
  lazygit,
  opencode,
  codex,
  tools,
  nh,
  atuin,
  niri,
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
  pathsBase = [
    kakoune
    zellij
    lazygit
    opencode
    codex
    tools
    nh
    atuin
    #intelli-shell
  ];
in
symlinkJoin {
  name = name;
  paths = pathsBase ++ lib.optionals wantGraphical [ niri ];
}
