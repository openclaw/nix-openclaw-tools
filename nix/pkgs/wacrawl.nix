{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.4.4/wacrawl_0.4.4_darwin_arm64.tar.gz";
      hash = "sha256-63UVfJDfaEuCHj/KScMIcfgfjOkflywFv9QaBY8KJxM=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.4.4/wacrawl_0.4.4_linux_amd64.tar.gz";
      hash = "sha256-L6wl67xsXun1Sh30qukWWKATGNleR70mK+V622yLcM0=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.4.4/wacrawl_0.4.4_linux_arm64.tar.gz";
      hash = "sha256-QfjsOpGKKb0tKAHSgQAthSRtleYADR/D6Kes50iVaqI=";
    };
  };
in
stdenv.mkDerivation {
  pname = "wacrawl";
  version = "0.4.4";

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
