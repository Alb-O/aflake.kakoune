{ symlinkJoin
, kakoune
, zellij
, lazygit
, opencode
, codex
}:
symlinkJoin {
  name = "kakoune-flake";
  paths = [
    kakoune
    zellij
    lazygit
    opencode
    codex
  ];
}
