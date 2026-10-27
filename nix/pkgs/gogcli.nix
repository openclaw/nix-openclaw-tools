{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.47.1/gogcli_0.47.1_darwin_arm64.tar.gz";
      hash = "sha256-QAeOSl1V6/Fr28mdT1wOPw1ejIYtU2QXrk6uPEAIVxo=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.47.1/gogcli_0.47.1_linux_amd64.tar.gz";
      hash = "sha256-J5vDoDwZGdd04mjvIplJ9Ft1Og4hJX+fsxWwW+ekDqk=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.47.1/gogcli_0.47.1_linux_arm64.tar.gz";
      hash = "sha256-xnesar9eGH6Yeof+G1iPRUsAKn1wGd6BuejbAunpArY=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.47.1";

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
