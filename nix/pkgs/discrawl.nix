{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.15.6/discrawl_0.15.6_darwin_arm64.tar.gz";
      hash = "sha256-jCZ5xeq1OFgyoUIJHs3UTw/AV1fHbQm2ah7GfXcT6+0=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.15.6/discrawl_0.15.6_linux_amd64.tar.gz";
      hash = "sha256-+sb3T1DC3ra9KobiV6aGtlzEJM9Yn7oxTLF/HhmqVE0=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.15.6/discrawl_0.15.6_linux_arm64.tar.gz";
      hash = "sha256-u4BhjnsmBmW8WJ/JAZTRqex6mbT05rN9LJywtYt6SWQ=";
    };
  };
in
stdenv.mkDerivation {
  pname = "discrawl";
  version = "0.15.6";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/share/doc/discrawl"
    cp $(find . -type f -name discrawl | head -1) "$out/bin/discrawl"
    chmod 0755 "$out/bin/discrawl"
    if [ -f LICENSE ]; then
      cp LICENSE "$out/share/doc/discrawl/"
    fi
    if [ -f README.md ]; then
      cp README.md "$out/share/doc/discrawl/"
    fi
    runHook postInstall
  '';

  meta = with lib; {
    description = "Mirror Discord into SQLite and search server history locally";
    homepage = "https://github.com/openclaw/discrawl";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "discrawl";
  };
}
