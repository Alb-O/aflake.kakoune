{ ... }@pkgs:
{
  kakoune = pkgs.callPackage ./kakoune { };
  zellij = pkgs.callPackage ./zellij { };
  lazygit = pkgs.callPackage ./lazygit { };
  opencode = pkgs.callPackage ./opencode { };
  codex = pkgs.callPackage ./codex { };
  tools = pkgs.callPackage ./tools { };
  nh = pkgs.callPackage ./nh { };
  atuin = pkgs.callPackage ./atuin { };
}
