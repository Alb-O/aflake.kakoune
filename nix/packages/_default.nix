{ symlinkJoin
, kakoune
, zellij
, lazygit
, opencode
, codex
, tools
, nh
, atuin
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
    atuin
  ];
}
