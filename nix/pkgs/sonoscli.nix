{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/sonoscli/releases/download/v0.3.1/sonoscli_0.3.1_darwin_arm64.tar.gz";
      hash = "sha256-6No+VjPpRWNE7wSSWLCMcP6qpzdJ/zX/SEB16nsc3Mg=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/sonoscli/releases/download/v0.3.1/sonoscli_0.3.1_linux_amd64.tar.gz";
      hash = "sha256-IlX6Bo4cV06eozR3yUPbsfolajyQwln3DwZnJolqckU=";
    };
    "aarch64-linux" = {
      url = "https://github.com/steipete/sonoscli/releases/download/v0.3.1/sonoscli_0.3.1_linux_arm64.tar.gz";
      hash = "sha256-AxXaEYYPa29yDz2XnoIlcpzvwGk8gOKnblhWl+jNl14=";
    };
  };
in
stdenv.mkDerivation {
  pname = "sonoscli";
  version = "0.3.1";

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
