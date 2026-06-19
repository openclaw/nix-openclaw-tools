{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.29.0/gogcli_0.29.0_darwin_arm64.tar.gz";
      hash = "sha256-ItGVEb+kRLKBEJIQIOgmeAkTvQqFgOmArZ9lETsLh2Q=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.29.0/gogcli_0.29.0_linux_amd64.tar.gz";
      hash = "sha256-IAGrjo4t+5eRavDfJbJzdj7Ca0njxCWWHmaJPKfQBp8=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.29.0/gogcli_0.29.0_linux_arm64.tar.gz";
      hash = "sha256-26w5OO1dVENUUxAdXGDOLRwscv7aO1P0t1o5W8UPCbk=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.29.0";

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
