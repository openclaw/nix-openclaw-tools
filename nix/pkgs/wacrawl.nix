{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/wacrawl/releases/download/v0.2.4/wacrawl_0.2.4_darwin_arm64.tar.gz";
      hash = "sha256-vn6GN8inl06EwYCRW0xlDJMaj3iFP82Dbdt5HpH/NMo=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/wacrawl/releases/download/v0.2.4/wacrawl_0.2.4_linux_amd64.tar.gz";
      hash = "sha256-kK4E24aJw4ItLK3lw3tsEbfcFe8OeR7/iOJlTInMRiA=";
    };
    "aarch64-linux" = {
      url = "https://github.com/steipete/wacrawl/releases/download/v0.2.4/wacrawl_0.2.4_linux_arm64.tar.gz";
      hash = "sha256-k033oRaYjGdU9JVdQn3yfjmxWw/UtSPsjRTisVGCsfs=";
    };
  };
in
stdenv.mkDerivation {
  pname = "wacrawl";
  version = "0.2.4";

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
