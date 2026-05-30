{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.20.0/gogcli_0.20.0_darwin_arm64.tar.gz";
      hash = "sha256-6ZFHDI1/GQ8JlWWRT/Lqy9aI/Cq84UTNJJbr8lw8BKw=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.20.0/gogcli_0.20.0_linux_amd64.tar.gz";
      hash = "sha256-jHhDHVpChq67BIh6nJy2GD+I6g+7878YAsivG1pnOmc=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.20.0/gogcli_0.20.0_linux_arm64.tar.gz";
      hash = "sha256-HPVq1WSXWbkMtnU3yEtZikN5TW3Q2FsoBJXBD2/5Qcc=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.20.0";

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
