{ pkgs }:
with pkgs; [
  kakoune-lsp
  rust-analyzer
  nil
  marksman
  nodePackages_latest.typescript-language-server
  nodePackages_latest.typescript
  vscode-langservers-extracted
  tailwindcss-language-server
]

