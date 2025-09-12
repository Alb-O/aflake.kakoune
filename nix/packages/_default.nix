{ symlinkJoin
, kakoune
, zellij
,
}:
symlinkJoin {
  name = "kakoune-flake";
  paths = [
    kakoune
    zellij
  ];
}
