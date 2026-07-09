{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.11.5/discrawl_0.11.5_darwin_arm64.tar.gz";
      hash = "sha256-H8Geu+92b85WVSADBZ/5BfoeqkaL0Y4SrXZsCoYHdn4=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.11.5/discrawl_0.11.5_linux_amd64.tar.gz";
      hash = "sha256-sl/CduA/vSKDbAGpWILK3HBJIClbny6qOFvf4BXBd1c=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.11.5/discrawl_0.11.5_linux_arm64.tar.gz";
      hash = "sha256-K9ZIW3wzTMdZ3zmqtqyDIe06F/nXEpuyHwz4SIHGp2c=";
    };
  };
in
stdenv.mkDerivation {
  pname = "discrawl";
  version = "0.11.5";

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
