{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/sag/releases/download/v0.4.5/sag_0.4.5_darwin_arm64.tar.gz";
      hash = "sha256-WcIv54Gs8pgRj+nq467s/ZW0714li9oaOBvSqu1LE2o=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/sag/releases/download/v0.4.5/sag_0.4.5_linux_amd64.tar.gz";
      hash = "sha256-GzpyoshLLqVyrN2cxm2lBKTP8xi4omrVLqpHB1Oi14k=";
    };
  };
in
stdenv.mkDerivation {
  pname = "sag";
  version = "0.4.5";

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
