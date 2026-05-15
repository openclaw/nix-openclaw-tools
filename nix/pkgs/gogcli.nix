{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.17.0/gogcli_0.17.0_darwin_arm64.tar.gz";
      hash = "sha256-rl/mcj+SUtz80xFkPrf8jD/HxaDBfU6LrVbzCbIL/N8=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.17.0/gogcli_0.17.0_linux_amd64.tar.gz";
      hash = "sha256-uEbEZRkU+gDDSXcW6zm7Z+erFJ5UvNLcmDZ79eD3kNc=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.17.0/gogcli_0.17.0_linux_arm64.tar.gz";
      hash = "sha256-YvbPwguIis63EfkKUZPXvf1d75SmHMXh6ZoKDHCCuKc=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.17.0";

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
