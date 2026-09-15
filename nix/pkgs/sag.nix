{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/sag/releases/download/v0.4.3/sag_0.4.3_darwin_arm64.tar.gz";
      hash = "sha256-e86BWIcPoBhtzOLKovnNqwhxtHnoySYbUSUMhiNjbxQ=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/sag/releases/download/v0.4.3/sag_0.4.3_linux_amd64.tar.gz";
      hash = "sha256-PXarJeQmBSYahMDg+Gxag6sY5pfRsKd0Uo6yYQMMTeI=";
    };
  };
in
stdenv.mkDerivation {
  pname = "sag";
  version = "0.4.3";

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
