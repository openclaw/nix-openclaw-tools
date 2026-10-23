{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/sonoscli/releases/download/v0.3.5/sonoscli_0.3.5_darwin_arm64.tar.gz";
      hash = "sha256-EcWC7E3O0sTVOZxsxOlr7UI93AToWGOw4dWd5USFgLI=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/sonoscli/releases/download/v0.3.5/sonoscli_0.3.5_linux_amd64.tar.gz";
      hash = "sha256-suum8TS5s48AeHj2e4XNwgSP3O03x4Es6incVzXnxWY=";
    };
    "aarch64-linux" = {
      url = "https://github.com/steipete/sonoscli/releases/download/v0.3.5/sonoscli_0.3.5_linux_arm64.tar.gz";
      hash = "sha256-NsWN5IDwaN28u4DaabQuXURHejx2Ty7SHxaFC45lnvA=";
    };
  };
in
stdenv.mkDerivation {
  pname = "sonoscli";
  version = "0.3.5";

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
