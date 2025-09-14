{ ... }@pkgs:
let
  cli = import ./cli pkgs;
  gui = import ./gui pkgs;
in
import ./_default.nix (pkgs // { inherit cli gui; })

