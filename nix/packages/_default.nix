{ symlinkJoin
, kakoune-wrapped
, zellij-wrapped
,
}:
symlinkJoin {
  name = "kakoune-flake";
  paths = [
    kakoune-wrapped
    zellij-wrapped
  ];
}
