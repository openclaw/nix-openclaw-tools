{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/gogcli/releases/download/v0.12.0/gogcli_0.12.0_darwin_arm64.tar.gz";
      hash = "sha256-03FmSb9taj8F6UvocEmRxp3Ghqz8hNNfHyiBL9JPEVE=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/gogcli/releases/download/v0.12.0/gogcli_0.12.0_linux_amd64.tar.gz";
      hash = "sha256-oD/MvWfqLlmialbpLeiRhXf0vr5LL5RoI0GXd4J82rI=";
    };
    "aarch64-linux" = {
      url = "https://github.com/steipete/gogcli/releases/download/v0.12.0/gogcli_0.12.0_linux_arm64.tar.gz";
      hash = "sha256-1/IElNfrDocWYxhT0FXMuzaMe4HLgWX1W0WIS8y2e0s=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.12.0";

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
