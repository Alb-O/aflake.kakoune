{ symlinkJoin, kakoune-wrapped }:
symlinkJoin {
  name = "kakoune-flake";
  paths = [ kakoune-wrapped ];
}

