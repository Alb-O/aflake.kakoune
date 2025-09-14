{
  description = "Kakoune";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flakelight.url = "github:nix-community/flakelight";
    wrapper-manager.url = "github:viperML/wrapper-manager";
  };

  outputs =
    { flakelight, ... }@inputs:
    flakelight ./. {
      inherit inputs;
      # packages are auto-loaded from ./nix/packages
      # Additionally, define aggregate outputs here to avoid auto-loader quirks.
      packages.default = pkgs:
        let
          cli = import ./nix/packages/cli/_index.nix pkgs;
          gui = import ./nix/packages/gui/_index.nix pkgs;
          isWSL = (builtins.getEnv "WSL_DISTRO_NAME" != "") || (builtins.getEnv "WSL_INTEROP" != "");
          wantGraphical = !isWSL;
        in
        pkgs.symlinkJoin {
          name = "kakoune-flake";
          paths = (builtins.attrValues cli)
            ++ pkgs.lib.optionals wantGraphical (builtins.attrValues gui);
        };
      packages.all = pkgs:
        let
          cli = import ./nix/packages/cli/_index.nix pkgs;
          gui = import ./nix/packages/gui/_index.nix pkgs;
        in
        pkgs.symlinkJoin {
          name = "kakoune-flake-all";
          paths = (builtins.attrValues cli) ++ (builtins.attrValues gui);
        };
      # Share LSPs + formatters in the devShell
      devShell.packages =
        pkgs:
        (import ./nix/lib/lsp.nix { pkgs = pkgs; }) ++ (import ./nix/lib/formatters.nix { pkgs = pkgs; });
    };
}
