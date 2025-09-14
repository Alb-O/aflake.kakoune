{ ... }@args:
let
  symlinkJoin = if args ? symlinkJoin then args.symlinkJoin else if args ? pkgs then args.pkgs.symlinkJoin else throw "symlinkJoin missing";
  lib = if args ? lib then args.lib else if args ? pkgs then args.pkgs.lib else throw "lib missing";
  # optional overrides via args
  forceAll = args.forceAll or false;
  name = args.name or "kakoune-flake";
in
let
  # simple WSL detection at eval time (whether to build graphical programs)
  isWSL = (builtins.getEnv "WSL_DISTRO_NAME" != "") || (builtins.getEnv "WSL_INTEROP" != "");
  wantGraphical = forceAll || (!isWSL);
  # Ensure category attrs are populated
  cliPkgs = if args ? cli then args.cli else import ../packages/cli args;
  guiPkgs = if args ? gui then args.gui else import ../packages/gui args;

  pathsBase =
    (builtins.attrValues cliPkgs);
in
symlinkJoin {
  name = name;
  paths = pathsBase ++ lib.optionals wantGraphical (builtins.attrValues guiPkgs);
}

