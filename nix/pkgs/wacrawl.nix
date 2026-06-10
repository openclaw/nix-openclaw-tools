{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.2.7/wacrawl_0.2.7_darwin_arm64.tar.gz";
      hash = "sha256-osPG77QSYo5vPk4v3WisAIPkIywitucD4X4mPp0cR80=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.2.7/wacrawl_0.2.7_linux_amd64.tar.gz";
      hash = "sha256-LEAvgeLWX9GOJtaGiWlyxoHMBy5ibq0u60xKzSxIkYY=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.2.7/wacrawl_0.2.7_linux_arm64.tar.gz";
      hash = "sha256-eeE6NUH4mYYgOpt5snMsNjMNOJqsQrq6siJnEtQdNEE=";
    };
  };
in
stdenv.mkDerivation {
  pname = "wacrawl";
  version = "0.2.7";

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
