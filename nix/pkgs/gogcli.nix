{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.23.0/gogcli_0.23.0_darwin_arm64.tar.gz";
      hash = "sha256-D3tdJUwD+D0hElpvgoPPGqBhSiqV5rj05zFhHCyP528=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.23.0/gogcli_0.23.0_linux_amd64.tar.gz";
      hash = "sha256-w8FisAtbutxOAFAkpRvoXNzRoBsXZH/ojrFTMw9s/zE=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.23.0/gogcli_0.23.0_linux_arm64.tar.gz";
      hash = "sha256-4O/2ivHzEFHoD4Ilw2wSPI2ywr8QvdLj5BCLTEPqj4g=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.23.0";

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
