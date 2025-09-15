{ inputs
, lib
, system
, ...
}@pkgs:
let
  fullPkgs = inputs.nixpkgs.legacyPackages.${system};
  haveFiletypes = builtins.pathExists ./filetypes;
  # Shared LSP packages (DRY within this flake)
  lspPkgs = import ../../../lib/lsp.nix { pkgs = fullPkgs; };
  # Shared formatter packages
  fmtPkgs = import ../../../lib/formatters.nix { pkgs = fullPkgs; };
  # Shared clipboard (wl-copy wrapper with WSL fallback)
  clipboard = import ../../../lib/clipboard.nix { pkgs = fullPkgs; };

  # Binaries we ensure are on PATH inside Kak's %sh blocks
  depsBinPath = lib.makeBinPath [ fullPkgs.lua ];

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
    # 1) Copy any plugin directories (e.g., git submodules) preserving structure
    for d in ${./plugins}/*; do
      if [ -d "$d" ]; then
        cp -a "$d" "$outdir/plugins/"
      fi
    done

    # 2) Copy standalone .kak files at the top level (keep them flat)
    while IFS= read -r f; do
      install -Dm444 "$f" "$outdir/plugins/$(basename "$f")"
    done < <(find ${./plugins} -maxdepth 1 -type f -name '*.kak' -print)

    # Optional filetypes
    ${lib.optionalString haveFiletypes ''
      while IFS= read -r f; do
        install -Dm444 "$f" "$outdir/filetypes/$(basename "$f")"
      done < <(find ${./filetypes} -type f -name '*.kak' -print)
    ''}
  '';

  kakouneLauncher = fullPkgs.writeShellScriptBin "kak" ''
    export PATH="${depsBinPath}:$PATH"
    exec -a "$0" "${fullPkgs.kakoune}/bin/kak" "$@"
  '';

  kakInNewTerm = pkgs.writeShellScriptBin "kakInNewTerm" ''
    $TERM sh -c "kak $@" &>/dev/null &
  '';

  kakouneDesktop = pkgs.writeTextDir "share/applications/kakoune.desktop" (
    lib.generators.toINI { } {
      "Desktop Entry" = {
        Name = "Kakoune";
        Type = "Application";
        TryExec = "kak";
        Exec = "${kakInNewTerm}/bin/kakInNewTerm %U";
        Terminal = true;
        Icon = "kakoune";
        Comment = "Edit text";
        GenericName = "Text Editor";
        StartupNotify = true;
        MimeType = "text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;text/markdown;text/x-python;application/x-yaml;application/json;text/rust;text/vnd.trolltech.linguist;application/javascript";
        Catagories = "Development;TextEditor;";
        StartupWMClass = "Kakoune";
      };
    }
  );

  wm = inputs.wrapper-manager.lib {
    pkgs = fullPkgs;
    inherit lib;
    modules = [
      {
        wrappers.kakoune = {
          wrapperType = "shell";
          basePackage = kakouneLauncher;
          extraPackages = [
            fullPkgs.kakoune
            config
            kakInNewTerm
            kakouneDesktop
            clipboard
          ]
          ++ lspPkgs
          ++ fmtPkgs;
          env = {
            KAKOUNE_CONFIG_DIR.value = "${config}/share/kak";
          };
        };
      }
    ];
  };
in
wm.config.wrappers.kakoune.wrapped
