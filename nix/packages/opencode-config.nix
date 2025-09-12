{ stdenvNoCC }:
stdenvNoCC.mkDerivation {
  pname = "ai-tools-config";
  version = "local";

  src = ./opencode;

  installPhase = ''
    mkdir -p $out/opencode
    cp -r config/* $out/opencode/
  '';
}
