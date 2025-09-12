{ stdenvNoCC, src }:
stdenvNoCC.mkDerivation {
  pname = "ai-tools-config";
  version = "local";

  src = src + "/config";

  installPhase = ''
    mkdir -p $out/opencode
    cp -r opencode/* $out/opencode/
  '';
}
