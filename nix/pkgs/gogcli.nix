{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.48.0/gogcli_0.48.0_darwin_arm64.tar.gz";
      hash = "sha256-qMYUL8ufQfDv8C/+94KYy+SYEGHxScKzpC1aE7rZMb0=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.48.0/gogcli_0.48.0_linux_amd64.tar.gz";
      hash = "sha256-iAnS9P6VoCmbGipca8kSxKukuQp7XiwfXPEbmUWlAAQ=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.48.0/gogcli_0.48.0_linux_arm64.tar.gz";
      hash = "sha256-/EBSQ2jSy2ITvf4Lc2tYhOG1XGNocG16KFVCy35Vm2g=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.48.0";

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
