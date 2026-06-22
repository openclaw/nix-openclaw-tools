{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.30.0/gogcli_0.30.0_darwin_arm64.tar.gz";
      hash = "sha256-9FHAHdXu0HlY4/nUDRuiyN+NCSqfsb5eXTqa/do1gHM=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.30.0/gogcli_0.30.0_linux_amd64.tar.gz";
      hash = "sha256-+fT0B7t2KVkIW0IAfE2lOLPa/Fx2tT86MNx/98Yjf8E=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.30.0/gogcli_0.30.0_linux_arm64.tar.gz";
      hash = "sha256-O6DOHCaLyVz4TGDGIuHky/O8JX7NbkR70c/N06oJQwo=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.30.0";

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
