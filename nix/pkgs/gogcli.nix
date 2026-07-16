{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.34.1/gogcli_0.34.1_darwin_arm64.tar.gz";
      hash = "sha256-kKuRBNVD0WrFNn1AXcYbiGADoRjOfq3dDdc8A2MUFEk=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.34.1/gogcli_0.34.1_linux_amd64.tar.gz";
      hash = "sha256-pbS+LqY11Mgwly3sHzqQsMoX+cJeemNT0eBo2FBeqYM=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.34.1/gogcli_0.34.1_linux_arm64.tar.gz";
      hash = "sha256-hRDbZJLCf3cEv2CvJ2807egbZ9iLb/z5UxU9qEHqo+0=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.34.1";

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
