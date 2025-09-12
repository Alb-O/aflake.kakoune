{ inputs
, lib
, system
, ...
}@pkgs:
let
  fullPkgs = inputs.nixpkgs.legacyPackages.${system};
  haveFiletypes = builtins.pathExists ./filetypes;
  # Shared LSP packages (DRY within this flake)
  lspPkgs = import ../../lib/lsp.nix { pkgs = fullPkgs; };

  # Package Kakoune config + local addons under share/kak
  config = fullPkgs.runCommand "kakoune-config" { } ''
    set -eu
    outdir=$out/share/kak
    mkdir -p "$outdir/colors" "$outdir/plugins" "$outdir/filetypes"

    # Main config
    install -Dm444 ${./kakrc} "$outdir/kakrc"

    # Colors
    while IFS= read -r f; do
      install -Dm444 "$f" "$outdir/colors/$(basename "$f")"
    done < <(find ${./colors} -type f -name '*.kak' -print)

    # Plugins
    while IFS= read -r f; do
      install -Dm444 "$f" "$outdir/plugins/$(basename "$f")"
    done < <(find ${./plugins} -type f -name '*.kak' -print)

    # Optional filetypes
    ${lib.optionalString haveFiletypes ''
    while IFS= read -r f; do
      install -Dm444 "$f" "$outdir/filetypes/$(basename "$f")"
    done < <(find ${./filetypes} -type f -name '*.kak' -print)
    ''}
  '';

  kakouneLauncher = fullPkgs.writeShellScriptBin "kak" ''
    exec -a "$0" "${fullPkgs.kakoune}/bin/kak" "$@"
  '';

  wm = inputs.wrapper-manager.lib {
    pkgs = fullPkgs;
    inherit lib;
    modules = [
      {
        wrappers.kakoune = {
          wrapperType = "shell";
          basePackage = kakouneLauncher;
          extraPackages =
            [
              fullPkgs.kakoune
              config
              fullPkgs.wl-clipboard
            ]
            ++ lspPkgs;
          env = {
            KAKOUNE_CONFIG_DIR.value = "${config}/share/kak";
          };
        };
      }
    ];
  };
in
wm.config.wrappers.kakoune.wrapped
