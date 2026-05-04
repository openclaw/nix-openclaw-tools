{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/goplaces/releases/download/v0.4.0/goplaces_0.4.0_darwin_arm64.tar.gz";
      hash = "sha256-FJ8hVqQhp/Ppk17CrDJk4dmu2pvS2xBX5cAzafpaM8g=";
    };
    "x86_64-darwin" = {
      url = "https://github.com/steipete/goplaces/releases/download/v0.4.0/goplaces_0.4.0_darwin_amd64.tar.gz";
      hash = "sha256-/vVK0hqh1q3tliSy4mRT9X3jRayYhWAfZLS+VsFd+NU=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/goplaces/releases/download/v0.4.0/goplaces_0.4.0_linux_amd64.tar.gz";
      hash = "sha256-cUHDAZ4Ep50K2ljLn8LyJeWPJlcr/sytP95UsNmSv3w=";
    };
    "aarch64-linux" = {
      url = "https://github.com/steipete/goplaces/releases/download/v0.4.0/goplaces_0.4.0_linux_arm64.tar.gz";
      hash = "sha256-YjeLRDLwuQbUOYZYnpNkuYDvsm54PB1jmqTHas2T5VY=";
    };
  };

  meta = with lib; {
    description = "Modern Go client + CLI for the Google Places API (New)";
    homepage = "https://github.com/steipete/goplaces";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "goplaces";
  };

in
stdenv.mkDerivation {
  pname = "goplaces";
  version = "0.4.0";

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
