{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/wacrawl/releases/download/v0.1.0/wacrawl_0.1.0_darwin_arm64.tar.gz";
      hash = "sha256-GJw2RODtrn1uOdduq9lSYAWzXVkSQPMBuiweyCwov6g=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/wacrawl/releases/download/v0.1.0/wacrawl_0.1.0_linux_amd64.tar.gz";
      hash = "sha256-cMNmH/Xj++5dAIiphVz7e7DYDwM2xx+RlEVxBKw7kJw=";
    };
    "aarch64-linux" = {
      url = "https://github.com/steipete/wacrawl/releases/download/v0.1.0/wacrawl_0.1.0_linux_arm64.tar.gz";
      hash = "sha256-QybKaF1lmqGVDUwqBLWfEtJwkT/BB9KsJgL1a/m40hQ=";
    };
  };
in
stdenv.mkDerivation {
  pname = "wacrawl";
  version = "0.1.0";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/share/doc/wacrawl"
    cp $(find . -type f -name wacrawl | head -1) "$out/bin/wacrawl"
    chmod 0755 "$out/bin/wacrawl"
    if [ -f LICENSE ]; then
      cp LICENSE "$out/share/doc/wacrawl/"
    fi
    if [ -f README.md ]; then
      cp README.md "$out/share/doc/wacrawl/"
    fi
    runHook postInstall
  '';

  meta = with lib; {
    description = "Read-only local archive and search for WhatsApp Desktop data";
    homepage = "https://github.com/steipete/wacrawl";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "wacrawl";
  };
}
