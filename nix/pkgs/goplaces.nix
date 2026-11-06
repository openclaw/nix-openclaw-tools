{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/goplaces/releases/download/v0.5.0/goplaces_0.5.0_darwin_arm64.tar.gz";
      hash = "sha256-nDm31i2PxTptF4o56fxT02hPBDJpljCLaLObqHQipOc=";
    };
    "x86_64-darwin" = {
      url = "https://github.com/openclaw/goplaces/releases/download/v0.5.0/goplaces_0.5.0_darwin_amd64.tar.gz";
      hash = "sha256-lwNMU4g+wCLexT7/HmlABzsoT80mJNswu0IJ6W8TWu8=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/goplaces/releases/download/v0.5.0/goplaces_0.5.0_linux_amd64.tar.gz";
      hash = "sha256-Qt02ACHAwnPxgPrbvzaQquA2x2uHs0F4WC0HGWhjwqI=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/goplaces/releases/download/v0.5.0/goplaces_0.5.0_linux_arm64.tar.gz";
      hash = "sha256-Ey5R5c1iQb/VGVZ+Hcs3bf+z3oMoinNolKSPoZh6TWo=";
    };
  };

  meta = with lib; {
    description = "Modern Go client + CLI for the Google Places API (New)";
    homepage = "https://github.com/openclaw/goplaces";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "goplaces";
  };

in
stdenv.mkDerivation {
  pname = "goplaces";
  version = "0.5.0";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/share/doc/goplaces"
    cp $(find . -type f -name goplaces | head -1) "$out/bin/goplaces"
    chmod 0755 "$out/bin/goplaces"
    if [ -f LICENSE ]; then
      cp LICENSE "$out/share/doc/goplaces/"
    fi
    if [ -f README.md ]; then
      cp README.md "$out/share/doc/goplaces/"
    fi
    runHook postInstall
  '';

  inherit meta;
}
