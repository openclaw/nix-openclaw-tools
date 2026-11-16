{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.5.1/wacrawl_0.5.1_darwin_arm64.tar.gz";
      hash = "sha256-IkP3Ubeg+VtY3itqLPFL4qlGuDsH4iAdQhsBCAppaj0=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.5.1/wacrawl_0.5.1_linux_amd64.tar.gz";
      hash = "sha256-CuPk46iS+ITk8I7IzzfM+TSx/CYaJqMITZjgQgu8gOY=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.5.1/wacrawl_0.5.1_linux_arm64.tar.gz";
      hash = "sha256-NTGXtOsOU3MseDcT6Fl30gBtlBBgle8NW/KWSnDT0Y4=";
    };
  };
in
stdenv.mkDerivation {
  pname = "wacrawl";
  version = "0.5.1";

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
