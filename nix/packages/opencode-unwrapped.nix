{ callPackage, models-dev }:
callPackage ./opencode/unwrapped.nix {
  inherit models-dev;
}

