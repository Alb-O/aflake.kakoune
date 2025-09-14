{
  inputs,
  lib,
  system,
  ...
}:
let
  fullPkgs = inputs.nixpkgs.legacyPackages.${system};
in
fullPkgs.runCommand "wezterm-terminfo" { } ''
  set -eu
  outdir="$out/share/terminfo"
  mkdir -p "$outdir"
  
  # Compile the terminfo file
  ${fullPkgs.ncurses}/bin/tic -o "$outdir" ${./wezterm.terminfo}
''