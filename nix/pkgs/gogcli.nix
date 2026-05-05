{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/gogcli/releases/download/v0.15.0/gogcli_0.15.0_darwin_arm64.tar.gz";
      hash = "sha256-WMc9nprZ+2m6Nd+MabD5eGXJ2XSmpRFfG7RuI/Ldl8k=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/gogcli/releases/download/v0.15.0/gogcli_0.15.0_linux_amd64.tar.gz";
      hash = "sha256-v6KpyAkr0ynbiaoQD4B0o/FCUePbcWuSdid5PkcUjJ0=";
    };
    "aarch64-linux" = {
      url = "https://github.com/steipete/gogcli/releases/download/v0.15.0/gogcli_0.15.0_linux_arm64.tar.gz";
      hash = "sha256-R3+DUVlX9asKDc9B/NSFSDF11PsY4O1hZXZsMQsqGzU=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.15.0";

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
