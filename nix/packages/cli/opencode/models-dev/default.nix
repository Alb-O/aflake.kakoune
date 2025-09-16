{ stdenv, fetchurl }:
stdenv.mkDerivation {
  pname = "models-dev";
  version = "latest";

  src = fetchurl {
    url = "https://models.dev/api.json";
    sha256 = "sha256-VuEhlqbbsAr2uX/QFNUWqsr5IbgThcdDKptOM2DL+UQ=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/dist
    cp $src $out/dist/_api.json
  '';
}
