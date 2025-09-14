{ ... }@pkgs:
let
  cli = import ./cli pkgs;
  gui = import ./gui pkgs;
in import ../lib/join-packages.nix (pkgs // { inherit cli gui; })
