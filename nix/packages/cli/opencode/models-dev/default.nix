{ stdenv, fetchurl }:
stdenv.mkDerivation {
  pname = "models-dev";
  version = "latest";

  src = fetchurl {
    url = "https://models.dev/api.json";
    sha256 = "sha256-bqMq/wj5XP4L0mtVipJUIvzwsz75ODaA++U3RdrQlrg=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/dist
    cp $src $out/dist/_api.json
  '';
}
