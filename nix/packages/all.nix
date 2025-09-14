{ ... }@pkgs:
import ./default.nix (pkgs // {
  forceAll = true;
  name = "kakoune-flake-all";
})
