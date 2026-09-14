{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/goplaces/releases/download/v0.4.11/goplaces_0.4.11_darwin_arm64.tar.gz";
      hash = "sha256-k4eJbIGuxHBlEO/WDdlY+99QVuapaN3eoQrU+XI5QCg=";
    };
    "x86_64-darwin" = {
      url = "https://github.com/openclaw/goplaces/releases/download/v0.4.11/goplaces_0.4.11_darwin_amd64.tar.gz";
      hash = "sha256-WuGUDysXJKNToHFmQQ3v2kLAdqwej4KEyB3t6SleSsU=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/goplaces/releases/download/v0.4.11/goplaces_0.4.11_linux_amd64.tar.gz";
      hash = "sha256-oLajAHaeUyECovZS+imBOibEVgjqQNg2/Zfq2Msl5lo=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/goplaces/releases/download/v0.4.11/goplaces_0.4.11_linux_arm64.tar.gz";
      hash = "sha256-Rfwk7QDYk+7yGH6/9j4Vk/yyHLgqCTt67s142y4hpac=";
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
  version = "0.4.11";

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
