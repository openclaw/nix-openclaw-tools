{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.47.0/gogcli_0.47.0_darwin_arm64.tar.gz";
      hash = "sha256-7ggmpFfz1EDlJy5BNaK/2YpseehzT1eJBV9vCVIxIK8=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.47.0/gogcli_0.47.0_linux_amd64.tar.gz";
      hash = "sha256-w+2U78qQx1TN2jAOPH+MwvPX34bT/cXRH5lsdRignCQ=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.47.0/gogcli_0.47.0_linux_arm64.tar.gz";
      hash = "sha256-kNI2q5HG2ucTm/4FCOq5SotDIyOLYvop5s9HmjUldvI=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.47.0";

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
