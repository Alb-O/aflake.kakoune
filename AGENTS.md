# Repository Guidelines

## Project Structure

- `flake.nix`, `flake.lock` — Nix flake entry.
- `nix/packages/` — package modules.
- `kakrc` — main Kakoune config (autoloads `filetypes/` and `plugins/`).
- `kakoune-wrapped.nix` — wrapper-manager config (sets `KAKOUNE_CONFIG_DIR`).
- `nix/lib/lsp.nix` — single source of truth for LSP packages shared across
  devShell and wrappers.
  - `plugins/` — add custom `.kak` files or whole plugin directories
    (git submodules supported; directory structure is preserved at
    `${KAKOUNE_CONFIG_DIR}/plugins/<name>/`).
- `result/` — build output after `nix build`.

## Build, Test, Develop

- Build: `nix build .#default`
- Run: `result/bin/kak`
- Headless smoke test: `result/bin/kak -ui dummy -e 'echo ok; quit'`
- Source a plugin (dummy):
  - Standalone file: `result/bin/kak -ui dummy -e 'source %val{config}/plugins/improved-insert-mode.kak; quit'`
  - Submodule dir: `result/bin/kak -ui dummy -e 'source %val{config}/plugins/luar/luar.kak; quit'`

## Environment Hooks (kakkle)

- Global EDITOR/VISUAL setup is provided via a profile hook.
- After `nix build .#default`:
  - Bash/Zsh: `source "$(readlink -f result)/share/profile.d/kakkle-env.sh"`.
- If installed via `nix profile install .#default` and your environment sources
  `$HOME/.nix-profile/etc/profile.d/*.sh`, EDITOR/VISUAL will be set on login.
- Do not set `TERM` globally. Instead:
  - Set `TERMINAL=kitty` via the same hook (already done).
  - Use `xdg-terminal` or `x-terminal-emulator` to spawn a terminal; they fall
    back to `$TERMINAL` or common emulators.

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
 - Modules: Kak now auto-requires any `provide-module <name>` found under
   `${KAKOUNE_CONFIG_DIR}/plugins/`. This makes submodule plugins (e.g.,
   `peneira`) expose their commands without manual `require-module` lines.

## Plugin Guidelines (Example)

- Place files in `nix/packages/plugins/` (lowercase, hyphenated names, add
  docstrings). Plugin directories (e.g., submodules like `peneira/` or
  `luar/`) are copied as-is under `plugins/`.
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

## Niri Packaging

- `niri` is now a standalone package at `nix/packages/niri`.
- It is not bundled in `.#default`; import or install `.#niri` separately (e.g.,
  in NixOS).
