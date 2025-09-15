# Agent Notes (Non‑Obvious Reminders)

- Build output lives in `result/`; run with `result/bin/kak`.
- Headless smoke test: `result/bin/kak -ui dummy -e 'echo ok; quit'`.
- Flakes only see tracked files. After adding anything under `nix/`, run
  `git add` before `nix build` to avoid missing attribute errors.
- Plugins are autoloaded from `${KAKOUNE_CONFIG_DIR}/plugins/` at startup.
  Peneira expects the line numbers highlighter to be named exactly
  `window/number-lines`.
