# Repository Guidelines

## Project Structure

- `flake.nix`, `flake.lock` — Nix flake entry.
- `nix/packages/` — package modules.
- `kakrc` — main Kakoune config (autoloads `filetypes/` and `plugins/`).
- `kakoune-wrapped.nix` — wrapper-manager config (sets `KAKOUNE_CONFIG_DIR`).
- `nix/lib/lsp.nix` — single source of truth for LSP packages shared across
  devShell and wrappers.
  - `plugins/` — add custom `.kak` files (e.g., `improved-insert-mode.kak`).
- `result/` — build output after `nix build`.

## Build, Test, Develop

- Build: `nix build .#default`
- Run: `result/bin/kak`
- Headless smoke test: `result/bin/kak -ui dummy -e 'echo ok; quit'`
- Source a plugin (dummy):
  `result/bin/kak -ui dummy -e 'source %val{config}/plugins/improved-insert-mode.kak; quit'`

## Fast Kakoune Docs & API Search

- Find installed docs: `fd -a '/share/kak/doc' /nix/store`
- Search commands/mappings:
  `rg -n "^==|^\*?map |^\*?commands" $(fd -a 'commands.asciidoc' /nix/store | rg kakoune)`
- Search hooks/completion:
  `rg -n "InsertCompletion(Show|Hide)|ModeChange|hook " $(fd -a 'hooks.asciidoc' /nix/store | rg kakoune)`
- Search highlighters/faces:
  `rg -n "add-highlighter|number-lines|Menu(Background|Foreground)" $(fd -a '*.asciidoc' /nix/store | rg '/kak/doc/')`
- In-editor docs: `:doc commands`, `:doc hooks`, `:doc mapping`,
  `:doc highlighters` (or `kak -ui dummy -e 'doc hooks; quit'`).
- Inspect wrapper env: `head -n 5 $(readlink -f result/bin/kak)` (look for
  `KAKOUNE_CONFIG_DIR`).

## Plugin Guidelines (Example)

- Place files in `nix/packages/plugins/` (lowercase, hyphenated names, add
  docstrings).
- Example snippet (completion keys and saves):
  - `hook global InsertCompletionShow .* %{ map window insert <tab> <c-n>; map window insert <s-tab> <c-p> }`
  - `map global normal <c-s> ': w<ret>'`
- Plugins are autoloaded from `${KAKOUNE_CONFIG_DIR}/plugins/` at startup.

## Commit & PRs

- Commits: imperative, scoped (e.g., `plugin: add improved insert mode`).
- PRs: include description, commands used to test, and any docs lookups
  performed.

## Git Tips

- Flakes only see files tracked by Git. After adding new modules under `nix/`
  (e.g., `nix/packages/zellij-wrapped.nix`), run `git add` before `nix build`.
  Otherwise evaluation may fail with missing attributes because untracked files
  are ignored.

## IntelliShell Integration

- Build: `nix build .#default` (includes IntelliShell) or `nix build .#intelli-shell`.
- Quick enable (writes to rc files): `result/bin/intelli-shell-activate`.
  - Appends a single `source …/profile.d/intelli-shell.sh` line to Bash/Zsh, or sources Fish init.
- No file writes (recommended for immutable/generator-managed rc):
  - Session-only: `source "$(readlink -f result)/share/profile.d/intelli-shell.sh"`.
  - Wrapper shells: `result/bin/ishell` (or `ishell-bash`, `ishell-zsh`, `ishell-fish`).
    - Set your terminal command to `result/bin/ishell` for automatic integration.
- Nix profile autoload: installing `.#intelli-shell` or `.#default` exposes
  `etc/profile.d/intelli-shell.sh`. If your environment sources
  `$HOME/.nix-profile/etc/profile.d/*.sh`, integration activates automatically.
- Hotkeys (override before sourcing the init):
  - Defaults: Search `Ctrl-Space`, Bookmark `Ctrl-B`, Variables `Ctrl-L`, Fix `Ctrl-X`.
  - Bash/Zsh: `export INTELLI_SEARCH_HOTKEY='\C-t'` (example).
  - Fish: `set -Ux INTELLI_SEARCH_HOTKEY \cT` (example).
- Verify:
  - Fish: `bind | rg -i intelli` (should show four bindings).
  - Bash/Zsh: run `intelli-shell --help` and try the hotkeys in an interactive shell.
