{ pkgs }:
with pkgs; [
  # Nix
  nixfmt
  # Rust
  rustfmt
  # Go
  go
  gofumpt
  # Shell
  shfmt
  # Lua
  stylua
  # JS/TS and friends
  nodePackages_latest.prettier
]

