{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.34.0/gogcli_0.34.0_darwin_arm64.tar.gz";
      hash = "sha256-j8xHHsS0767ndawpY9qWa9GNlduQQnS1e8u+zoULgOQ=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.34.0/gogcli_0.34.0_linux_amd64.tar.gz";
      hash = "sha256-dIX0/Yzp9+xiq/vrTfGdehGtHU6exv8uOaypcxRMb7g=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.34.0/gogcli_0.34.0_linux_arm64.tar.gz";
      hash = "sha256-7E5nxkqr8xByk5BdTm4qyzXIuIz7Dir2zVLCezTM1DY=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.34.0";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp gog "$out/bin/gog"
    chmod 0755 "$out/bin/gog"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Google CLI for Gmail, Calendar, Drive, and Contacts";
    homepage = "https://github.com/openclaw/gogcli";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "gog";
  };
}
