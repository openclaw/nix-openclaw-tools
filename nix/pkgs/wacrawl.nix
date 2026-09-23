{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.4.0/wacrawl_0.4.0_darwin_arm64.tar.gz";
      hash = "sha256-zgwRMbuF7bGatwaSE7RJbbiL9SMJG0J/ITKc5FPNewE=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.4.0/wacrawl_0.4.0_linux_amd64.tar.gz";
      hash = "sha256-oQNnRWuF6UFLI9dKscP/ic69K00pcn9GFscKfAvOM/g=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.4.0/wacrawl_0.4.0_linux_arm64.tar.gz";
      hash = "sha256-5sIT7EiPeFuw/zFjMUcWTKlWooNoC4YExcNLFdv4A+c=";
    };
  };
in
stdenv.mkDerivation {
  pname = "wacrawl";
  version = "0.4.0";

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
