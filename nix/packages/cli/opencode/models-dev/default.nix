{ stdenv, fetchurl }:
stdenv.mkDerivation {
  pname = "models-dev";
  version = "latest";

  src = fetchurl {
    url = "https://models.dev/api.json";
    sha256 = "sha256-nJBhNfx9WuN8M6tK8Z7Cs9S8Gi9FM759JegizrMhSCY=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/dist
    cp $src $out/dist/_api.json
  '';
}
