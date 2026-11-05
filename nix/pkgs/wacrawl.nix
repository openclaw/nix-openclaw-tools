{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.5.0/wacrawl_0.5.0_darwin_arm64.tar.gz";
      hash = "sha256-WY0Kt/h4fAwjaPA+VZvjfF7S+4nmPuwA5YxqK1FY/QM=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.5.0/wacrawl_0.5.0_linux_amd64.tar.gz";
      hash = "sha256-6NM4hyr8Awq2lEJS+tH8oEvoKznn8gLLS2fjo50Fej8=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.5.0/wacrawl_0.5.0_linux_arm64.tar.gz";
      hash = "sha256-oXga1WEGdFubryHbSkLwzAWVFrgJc2RofjTkAvTAVs8=";
    };
  };
in
stdenv.mkDerivation {
  pname = "wacrawl";
  version = "0.5.0";

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
