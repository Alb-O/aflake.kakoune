{ ... }@pkgs:
let
  # Import new category exports
  cli = import ./cli pkgs;
  gui = import ./gui pkgs;
in import ../lib/join-packages.nix (pkgs // {
  inherit cli gui;
  forceAll = true;
  name = "kakoune-flake-all";
})
