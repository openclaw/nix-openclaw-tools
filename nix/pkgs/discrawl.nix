{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.15.4/discrawl_0.15.4_darwin_arm64.tar.gz";
      hash = "sha256-wTsM2ZA4Hy855LFyhJsEefyl9HZbWNz6ixq6Bpra69o=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.15.4/discrawl_0.15.4_linux_amd64.tar.gz";
      hash = "sha256-lyx5Ws+OR5kk/mkl7NUw58mcUR4lIyR/jtWqfFEaaL0=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.15.4/discrawl_0.15.4_linux_arm64.tar.gz";
      hash = "sha256-TzZmmfOI1DhIN39CvSB2sdNvEUvV91chWzUL25BF9w4=";
    };
  };
in
stdenv.mkDerivation {
  pname = "discrawl";
  version = "0.15.4";

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
