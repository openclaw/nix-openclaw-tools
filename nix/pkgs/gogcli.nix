{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.48.1/gogcli_0.48.1_darwin_arm64.tar.gz";
      hash = "sha256-77VvJAD89qfyWuOKHhZftPn1/X97GOdrTAuCweNbgC8=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.48.1/gogcli_0.48.1_linux_amd64.tar.gz";
      hash = "sha256-3NlW4J0SIqB8EwTYNvis1VJmsvokHvRmWAztagJFPXI=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.48.1/gogcli_0.48.1_linux_arm64.tar.gz";
      hash = "sha256-wJH6IBTcPVYIrO9NCfs7tKPrceTP+Ji16t3ZcDWZ5Fw=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.48.1";

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
