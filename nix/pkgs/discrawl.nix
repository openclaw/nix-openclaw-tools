{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.15.0/discrawl_0.15.0_darwin_arm64.tar.gz";
      hash = "sha256-scQs7ZUWWg9XCC2/QGK2FWmS4jhb+Zo+gB8wijlLK/A=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.15.0/discrawl_0.15.0_linux_amd64.tar.gz";
      hash = "sha256-i3ygK5gishcySbgIfnv1T0xHNmuMbrDJ7x0luSXVfaI=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.15.0/discrawl_0.15.0_linux_arm64.tar.gz";
      hash = "sha256-pTM31ChTFwDywQ6CMuQEF6olbkCD33ORbOVhEUQZ5c8=";
    };
  };
in
stdenv.mkDerivation {
  pname = "discrawl";
  version = "0.15.0";

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
