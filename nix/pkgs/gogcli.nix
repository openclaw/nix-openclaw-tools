{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.42.0/gogcli_0.42.0_darwin_arm64.tar.gz";
      hash = "sha256-apKzVHPtBXxVZ3wrp9WvjhVNG60j+jXnSZS8LzvORnI=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.42.0/gogcli_0.42.0_linux_amd64.tar.gz";
      hash = "sha256-GWepYqV9aJlYxAjdCrx4R5LDcS2p0KkGULt2q34944g=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.42.0/gogcli_0.42.0_linux_arm64.tar.gz";
      hash = "sha256-hM4wAqzqFiWWBoyLJeNkqt5jTSBK5hIrcU5obKeDsCg=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.42.0";

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
