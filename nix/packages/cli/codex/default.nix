{ writeShellApplication, nodejs, ... }:
writeShellApplication {
  name = "codex";
  runtimeInputs = [ nodejs ];
  text = ''
    exec ${nodejs}/bin/npx -y @openai/codex "$@"
  '';
}
