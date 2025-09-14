{ symlinkJoin, lib, ... }@args:
let
  forceAll = args.forceAll or false;
  name = args.name or "kakoune-flake";
  cli = import ./cli args;
  gui = import ./gui args;

  isWSL = (builtins.getEnv "WSL_DISTRO_NAME" != "") || (builtins.getEnv "WSL_INTEROP" != "");
  wantGraphical = forceAll || (!isWSL);
  pathsBase = builtins.attrValues cli;
in symlinkJoin {
  name = name;
  paths = pathsBase ++ lib.optionals wantGraphical (builtins.attrValues gui);
}
