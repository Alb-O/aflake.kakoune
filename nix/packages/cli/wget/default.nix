{ ... }@pkgs:
# Expose the wget wrapped package under a program-scoped path.
(import ./wrapped.nix pkgs)