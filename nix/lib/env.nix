{ pkgs ? null }:
{
  # Global, safe defaults. Avoid setting TERM globally.
  EDITOR = "kak";
  VISUAL = "kak";
  # Preferred terminal emulator command for programs to spawn
  TERMINAL = "kitty";
}
