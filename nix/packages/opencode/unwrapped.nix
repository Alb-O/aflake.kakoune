{ callPackage, models-dev }:
callPackage ../opencode-git.nix {
  inherit models-dev;
}
