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
      devShell.packages = pkgs: import ./nix/lib/lsp.nix { pkgs = pkgs; };
    };
}
