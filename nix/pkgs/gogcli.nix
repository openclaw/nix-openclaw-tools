{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.28.0/gogcli_0.28.0_darwin_arm64.tar.gz";
      hash = "sha256-Pr2FtKClDZm1ceF9EbM9hv3ofxyCzuD6zn86JcelJLM=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.28.0/gogcli_0.28.0_linux_amd64.tar.gz";
      hash = "sha256-UHakHvH9CVc+IFWcGRHeO6erywi/9heIhnowLT0tkNg=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/gogcli/releases/download/v0.28.0/gogcli_0.28.0_linux_arm64.tar.gz";
      hash = "sha256-wohxURq8jedYjqBp2AkJNSIcycZnlWIm6rzR/FHRncQ=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.28.0";

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
