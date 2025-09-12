{ symlinkJoin
, kakoune
, zellij
, lazygit
, opencode
, codex
, tools
}:
symlinkJoin {
  name = "kakoune-flake";
  paths = [
    kakoune
    zellij
    lazygit
    opencode
    codex
    tools
  ];
}
