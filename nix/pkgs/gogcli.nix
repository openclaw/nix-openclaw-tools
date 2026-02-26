{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/joshp123/gogcli/releases/download/v0.11.1/gogcli_0.11.1_darwin_arm64.tar.gz";
      hash = "sha256-fNc6D2VSh8xZypTWd9c2GM9dWSUUuTVbQ5sqXIqCUCA=";
    };
    "x86_64-linux" = {
      url = "https://github.com/joshp123/gogcli/releases/download/v0.11.1/gogcli_0.11.1_linux_amd64.tar.gz";
      hash = "sha256-+VfeOurErs/UnBTKcld2gQOUYxTNz5LyzOjOY6j2R5Y=";
    };
    "aarch64-linux" = {
      url = "https://github.com/joshp123/gogcli/releases/download/v0.11.1/gogcli_0.11.1_linux_arm64.tar.gz";
      hash = "sha256-20hyAqf4QGh5QQtIKtoFd8jn4yza1hjQr9eZ22pi73I=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.11.1";

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
    homepage = "https://github.com/steipete/gogcli";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "gog";
  };
}
