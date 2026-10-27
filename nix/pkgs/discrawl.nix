{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.18.0/discrawl_0.18.0_darwin_arm64.tar.gz";
      hash = "sha256-3LdLjkUHisIVh1tvK/E2subF1kttn/o32uW/H5KJetc=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.18.0/discrawl_0.18.0_linux_amd64.tar.gz";
      hash = "sha256-bGIY08R+X8HB5n5Fs/UdTForxmpTW8y6L2ejTgYcQyg=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.18.0/discrawl_0.18.0_linux_arm64.tar.gz";
      hash = "sha256-mzGYsUuYlrQUXU96mteSRmgq2N26nk9If8IS5Km2tvA=";
    };
  };
in
stdenv.mkDerivation {
  pname = "discrawl";
  version = "0.18.0";

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
