{ ... }@pkgs:
import ./_default.nix (pkgs // {
  forceAll = true;
  name = "kakoune-flake-all";
})

