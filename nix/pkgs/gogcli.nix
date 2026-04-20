{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/gogcli/releases/download/v0.13.0/gogcli_0.13.0_darwin_arm64.tar.gz";
      hash = "sha256-fG9lD3UWMj3dAD5Kur+Zj8HSxzCJpGYrjHm/gKxL31Y=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/gogcli/releases/download/v0.13.0/gogcli_0.13.0_linux_amd64.tar.gz";
      hash = "sha256-of4lxHzDKXxmldYcGws6u36IY0sR6G13vA2TA3cofj0=";
    };
    "aarch64-linux" = {
      url = "https://github.com/steipete/gogcli/releases/download/v0.13.0/gogcli_0.13.0_linux_arm64.tar.gz";
      hash = "sha256-HorxoDwpmFWk6Wi3L6q+/vIw967jfSvzZq6S8uGSktQ=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.13.0";

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
