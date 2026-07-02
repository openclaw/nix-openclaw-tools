{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.11.4/discrawl_0.11.4_darwin_arm64.tar.gz";
      hash = "sha256-KqLRPax10MzKuquLqKyDMUMQtuOaJ+5ZD0kzxJh5gjA=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.11.4/discrawl_0.11.4_linux_amd64.tar.gz";
      hash = "sha256-JUCnV4+yfEQyY8PIwSnn/zeuaLd9iBe32M9CMeboC/c=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.11.4/discrawl_0.11.4_linux_arm64.tar.gz";
      hash = "sha256-ov+Pnds4BCdBFJ2ywTHTNmN/7PQ9PTzqBr+TKTuGhAA=";
    };
  };
in
stdenv.mkDerivation {
  pname = "discrawl";
  version = "0.11.4";

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
