{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/wacrawl/releases/download/v0.2.5/wacrawl_0.2.5_darwin_arm64.tar.gz";
      hash = "sha256-ntInATW3A3/Y2zSCTjDL1us2/LLxTot8dRiUif+Q5f4=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/wacrawl/releases/download/v0.2.5/wacrawl_0.2.5_linux_amd64.tar.gz";
      hash = "sha256-T8MCHwSdgY4rSnBqOxnz6wUHbP9h0t27U3i/L7NQutc=";
    };
    "aarch64-linux" = {
      url = "https://github.com/steipete/wacrawl/releases/download/v0.2.5/wacrawl_0.2.5_linux_arm64.tar.gz";
      hash = "sha256-QgkX97kCH0fapdEK3w/J/U19XZqP8iVoWwxIABF9sd8=";
    };
  };
in
stdenv.mkDerivation {
  pname = "wacrawl";
  version = "0.2.5";

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
