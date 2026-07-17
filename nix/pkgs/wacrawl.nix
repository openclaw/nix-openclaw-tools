{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.3.3/wacrawl_0.3.3_darwin_arm64.tar.gz";
      hash = "sha256-cKaYJOXccdq/LcNwdZjJusUWWH21Tcn9ewMYeWJ6jWs=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.3.3/wacrawl_0.3.3_linux_amd64.tar.gz";
      hash = "sha256-T7c9foYF0QmaHsw8Zmpjax0f8FX98hqQQ9W4kA+BccM=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.3.3/wacrawl_0.3.3_linux_arm64.tar.gz";
      hash = "sha256-pmMMsuvDSEy0PEaGOMp6kzxNjZ6wo8p0sZgX2o0yYXU=";
    };
  };
in
stdenv.mkDerivation {
  pname = "wacrawl";
  version = "0.3.3";

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
