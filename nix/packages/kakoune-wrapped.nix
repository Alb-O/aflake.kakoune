{ inputs
, lib
, system
, ...
}@pkgs:
let
  # Use full nixpkgs for wrapper-manager eval
  fullPkgs = inputs.nixpkgs.legacyPackages.${system};
  haveFiletypes = builtins.pathExists ./filetypes;

  # Create a package containing Kakoune config and any local addons
  config = fullPkgs.runCommand "kakoune-config" { } ''
    set -eu
    outdir=$out/share/kak
    mkdir -p "$outdir/colors" "$outdir/plugins" "$outdir/filetypes"

    # Main config
    install -Dm444 ${./kakrc} "$outdir/kakrc"

    # Copy all .kak colors and plugins recursively; flatten filenames
    while IFS= read -r f; do
      install -Dm444 "$f" "$outdir/colors/$(basename "$f")"
    done < <(find ${./colors} -type f -name '*.kak' -print)

    while IFS= read -r f; do
      install -Dm444 "$f" "$outdir/plugins/$(basename "$f")"
    done < <(find ${./plugins} -type f -name '*.kak' -print)

    # Optional: ship filetype helpers if present
    ${lib.optionalString haveFiletypes ''
    while IFS= read -r f; do
      install -Dm444 "$f" "$outdir/filetypes/$(basename "$f")"
    done < <(find ${./filetypes} -type f -name '*.kak' -print)
    ''}
  '';

  # A tiny launcher for kakoune
  kakouneLauncher = fullPkgs.writeShellScriptBin "kakoune" ''
    exec -a "$0" "${fullPkgs.kakoune}/bin/kak" "$@"
  '';

  wm = inputs.wrapper-manager.lib {
    pkgs = fullPkgs;
    inherit lib;
    modules = [
      {
        wrappers.kakoune = {
          # Use shell wrappers for all binaries in this bundle
          wrapperType = "shell";
          # Use our custom launcher as the primary binary, but also ship upstream
          basePackage = kakouneLauncher;
          extraPackages = [
            fullPkgs.kakoune
            config
            # LSP client and servers
            fullPkgs.kakoune-lsp
            fullPkgs.rust-analyzer
            fullPkgs.nil
            fullPkgs.marksman
            fullPkgs.nodePackages_latest.typescript-language-server
            fullPkgs.nodePackages_latest.typescript
            fullPkgs.vscode-langservers-extracted
            fullPkgs.tailwindcss-language-server
            fullPkgs.wl-clipboard
          ];

          # Point Kakoune to this flake's config directory explicitly.
          # Using KAKOUNE_CONFIG_DIR avoids depending on a user's XDG_CONFIG_HOME.
          env = {
            KAKOUNE_CONFIG_DIR.value = "${config}/share/kak";
          };
        };
      }
    ];
  };
in
wm.config.wrappers.kakoune.wrapped
