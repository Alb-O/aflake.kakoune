{ ... }@pkgs:
{
  kakoune = import ./kakoune pkgs;
  zellij = import ./zellij pkgs;
  lazygit = import ./lazygit pkgs;
  opencode = import ./opencode pkgs;
  codex = import ./codex pkgs;
  tools = import ./tools pkgs;
  nh = import ./nh pkgs;
  env = import ./env pkgs;
  xdg-terminal = import ./xdg-terminal pkgs;
  zk = import ./zk pkgs;
  wget = import ./wget pkgs;
}
