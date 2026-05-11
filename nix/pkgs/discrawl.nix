{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.7.1/discrawl_0.7.1_darwin_arm64.tar.gz";
      hash = "sha256-T0xPj2gCkzH7BRRALEqrdA4XtnwDLfzpuTrnnNrdhlk=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.7.1/discrawl_0.7.1_linux_amd64.tar.gz";
      hash = "sha256-nuwIXw2goJbNhJscGG5aNvC/a3NIdfOZ1VIfyhYKIZQ=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.7.1/discrawl_0.7.1_linux_arm64.tar.gz";
      hash = "sha256-kiyd1fS1xgP3HxH2uZGbapSNeDtMJXfvfMP4wEAZNsg=";
    };
  };
in
stdenv.mkDerivation {
  pname = "discrawl";
  version = "0.7.1";

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
