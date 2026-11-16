{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/sonoscli/releases/download/v0.3.6/sonoscli_0.3.6_darwin_arm64.tar.gz";
      hash = "sha256-8PN3fVDQUPmMXNJbRKg5+/7/DU4XP/E8Vw97NWTw9Q0=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/sonoscli/releases/download/v0.3.6/sonoscli_0.3.6_linux_amd64.tar.gz";
      hash = "sha256-ivNWc5ezeCLPMmDNTXnPqf3/rVzc9Kljx1BqL1pJENs=";
    };
    "aarch64-linux" = {
      url = "https://github.com/steipete/sonoscli/releases/download/v0.3.6/sonoscli_0.3.6_linux_arm64.tar.gz";
      hash = "sha256-K0Gd4+fKy/YVdiQkZKt8otWU9bfyJ4+cTSapai+bcuo=";
    };
  };
in
stdenv.mkDerivation {
  pname = "sonoscli";
  version = "0.3.6";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/share/doc/sonoscli"
    cp $(find . -type f -name sonos | head -1) "$out/bin/sonos"
    chmod 0755 "$out/bin/sonos"
    if [ -f LICENSE ]; then
      cp LICENSE "$out/share/doc/sonoscli/"
    fi
    if [ -f README.md ]; then
      cp README.md "$out/share/doc/sonoscli/"
    fi
    runHook postInstall
  '';

  meta = with lib; {
    description = "Control Sonos speakers from the command-line";
    homepage = "https://github.com/steipete/sonoscli";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "sonos";
  };
}
