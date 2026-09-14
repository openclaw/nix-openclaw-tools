{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/sag/releases/download/v0.4.2/sag_0.4.2_darwin_universal.tar.gz";
      hash = "sha256-v6tpivbgrqBZC3T2ZnrFDt1eQwVyvmkEBCZlKezlOVQ=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/sag/releases/download/v0.4.2/sag_0.4.2_linux_amd64.tar.gz";
      hash = "sha256-F37LraEBpThCTX+MOWEHHxWoobQzZfFpsNmmm6gl3fs=";
    };
  };
in
stdenv.mkDerivation {
  pname = "sag";
  version = "0.4.2";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp sag "$out/bin/sag"
    chmod 0755 "$out/bin/sag"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Command-line ElevenLabs TTS with mac-style flags";
    homepage = "https://github.com/steipete/sag";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "sag";
  };
}
