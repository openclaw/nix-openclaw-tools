{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.11.7/discrawl_0.11.7_darwin_arm64.tar.gz";
      hash = "sha256-y+3Z/cyeWBKoMkd0XJQ6xI3ACkP8kYzbvTPBsnwvaYA=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.11.7/discrawl_0.11.7_linux_amd64.tar.gz";
      hash = "sha256-kzBk3JqEoN1LQHA3y7Q2zCadkHMZRqkjIxBymQgA+6E=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.11.7/discrawl_0.11.7_linux_arm64.tar.gz";
      hash = "sha256-gixXPhRRTguF5cwV4+M9Y53fhy7jUtM5JBkrGtXNYMg=";
    };
  };
in
stdenv.mkDerivation {
  pname = "discrawl";
  version = "0.11.7";

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
