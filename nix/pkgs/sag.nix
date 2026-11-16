{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/sag/releases/download/v0.4.6/sag_0.4.6_darwin_arm64.tar.gz";
      hash = "sha256-vNdTmSZra4qCxHijK87uF02et0XtcK+8+nJLT9xoEtI=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/sag/releases/download/v0.4.6/sag_0.4.6_linux_amd64.tar.gz";
      hash = "sha256-B1YH2eaAY/Ul50YtS9UXH26UsLY9jS9Uo1jRzgw48Vw=";
    };
  };
in
stdenv.mkDerivation {
  pname = "sag";
  version = "0.4.6";

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
