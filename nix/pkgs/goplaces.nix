{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/goplaces/releases/download/v0.4.4/goplaces_0.4.4_darwin_arm64.tar.gz";
      hash = "sha256-r3bAJkA+k6yVI2NArjf6U6AzHug5UOBWOsP/Wt/iTfw=";
    };
    "x86_64-darwin" = {
      url = "https://github.com/openclaw/goplaces/releases/download/v0.4.4/goplaces_0.4.4_darwin_amd64.tar.gz";
      hash = "sha256-FuwCNI+qOlSb0Vhv7REoxUPmHhNSzhK30IdMtlvQ05Q=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/goplaces/releases/download/v0.4.4/goplaces_0.4.4_linux_amd64.tar.gz";
      hash = "sha256-ppPlmKVn26dBUkEUHrQMj+erDl0oK3y8N6mzt2Dz9jQ=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/goplaces/releases/download/v0.4.4/goplaces_0.4.4_linux_arm64.tar.gz";
      hash = "sha256-QNeUBg51uAHBo7+AoTFednYVq8RiW9F628nXaI4iTx4=";
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
  version = "0.4.4";

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
