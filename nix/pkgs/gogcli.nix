{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.16.0/gogcli_0.16.0_darwin_arm64.tar.gz";
      hash = "sha256-jRbPp3fHEzd7WLrscfbsf2isF7r5NyTIhctfAurJN5c=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.16.0/gogcli_0.16.0_linux_amd64.tar.gz";
      hash = "sha256-Rsj/pxpOQl5ohbkm8cZ754mfREyeJUro2pxG6il6a9o=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.16.0/gogcli_0.16.0_linux_arm64.tar.gz";
      hash = "sha256-oRyo2S4BYkd8I66QH+NtUffOvZ4R0DINpNEFhPgjUyQ=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.16.0";

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
