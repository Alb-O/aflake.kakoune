{ symlinkJoin
, kakoune
, zellij
, lazygit
, opencode
, codex
, tools
, nh
, atuin
, intelli-shell
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
    intelli-shell
  ];
}
