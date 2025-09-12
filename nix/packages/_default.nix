{ symlinkJoin
, kakoune
, zellij
, lazygit
,
}:
symlinkJoin {
  name = "kakoune-flake";
  paths = [
    kakoune
    zellij
    lazygit
  ];
}
