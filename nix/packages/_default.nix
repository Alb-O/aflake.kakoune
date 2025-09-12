{ symlinkJoin
, kakoune
, zellij
, lazygit
, opencode
, codex
, tools
, nh
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
    nh
  ];
}
