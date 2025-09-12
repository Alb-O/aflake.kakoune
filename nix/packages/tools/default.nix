{ symlinkJoin, inputs, system, lib, ... }@pkgs:
let
  fullPkgs = inputs.nixpkgs.legacyPackages.${system};
in
symlinkJoin {
  name = "cli-tools";
  paths = [
    fullPkgs.jq
    fullPkgs.ripgrep
    fullPkgs.fd
    fullPkgs.eza
    fullPkgs.file
    fullPkgs.fastfetch
    fullPkgs.xdg-ninja
    fullPkgs.just
  ];
}
