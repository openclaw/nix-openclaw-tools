{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.8.0/discrawl_0.8.0_darwin_arm64.tar.gz";
      hash = "sha256-T5VCtxdh6wLEy3UOoyWrXMKVdvWDNEKDhve6pf2CDsE=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.8.0/discrawl_0.8.0_linux_amd64.tar.gz";
      hash = "sha256-0syDLLIgdv2cBF71PgxDxA4cqG7xnw/m2fpOM6nT9TY=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.8.0/discrawl_0.8.0_linux_arm64.tar.gz";
      hash = "sha256-3iXUtb8R6K68ZcfxxqcozX5804im68pAHP1HmD3juL4=";
    };
  };
in
stdenv.mkDerivation {
  pname = "discrawl";
  version = "0.8.0";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/share/doc/discrawl"
    cp $(find . -type f -name discrawl | head -1) "$out/bin/discrawl"
    chmod 0755 "$out/bin/discrawl"
    if [ -f LICENSE ]; then
      cp LICENSE "$out/share/doc/discrawl/"
    fi
    if [ -f README.md ]; then
      cp README.md "$out/share/doc/discrawl/"
    fi
    runHook postInstall
  '';

  meta = with lib; {
    description = "Mirror Discord into SQLite and search server history locally";
    homepage = "https://github.com/openclaw/discrawl";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "discrawl";
  };
}
