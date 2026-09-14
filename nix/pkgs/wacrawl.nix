{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.3.13/wacrawl_0.3.13_darwin_arm64.tar.gz";
      hash = "sha256-HF0H7RKHlaYYG8f3VvfXbsaKohKPYeppC6oaaxwqp5Y=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.3.13/wacrawl_0.3.13_linux_amd64.tar.gz";
      hash = "sha256-2Y6vMUofgTc0NkGz1d76/+Ds6AmWJixI6p9/vIUdAKM=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.3.13/wacrawl_0.3.13_linux_arm64.tar.gz";
      hash = "sha256-GDei65uLwmgLBWv509fscG4pe3xEYkXwSg7RTBt0lM4=";
    };
  };
in
stdenv.mkDerivation {
  pname = "wacrawl";
  version = "0.3.13";

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
