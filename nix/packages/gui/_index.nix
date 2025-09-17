{ ... }@pkgs:
{
  kitty = import ./kitty pkgs;
  wezterm = import ./wezterm pkgs;
  setup-background-terminals = import ./setup-background-terminals pkgs;
}
