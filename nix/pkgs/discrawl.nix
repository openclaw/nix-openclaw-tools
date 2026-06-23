{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.11.2/discrawl_0.11.2_darwin_arm64.tar.gz";
      hash = "sha256-vI4+SgclXK/fd5FhoUIwJ/MovrSaMzyBdCP2/lh2+Ww=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.11.2/discrawl_0.11.2_linux_amd64.tar.gz";
      hash = "sha256-TX+kr6M2uf/LIiddd8KED2uYX7x4Z9IV8p5+Rkkim3Q=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.11.2/discrawl_0.11.2_linux_arm64.tar.gz";
      hash = "sha256-NjMa9BaIDepeJWFpX839wcSkmp2ev59ZCN7Nz1Wh6D0=";
    };
  };
in
stdenv.mkDerivation {
  pname = "discrawl";
  version = "0.11.2";

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
