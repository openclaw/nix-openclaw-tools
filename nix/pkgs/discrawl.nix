{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.17.0/discrawl_0.17.0_darwin_arm64.tar.gz";
      hash = "sha256-whoO4kJ7GOiOAejc86swj9CklpvPxMbFKTPvZ72q5B0=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.17.0/discrawl_0.17.0_linux_amd64.tar.gz";
      hash = "sha256-vDAQch9+KjV2akFmPLzG9GEf4hH1OhMQTXyq/zF6Dj8=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.17.0/discrawl_0.17.0_linux_arm64.tar.gz";
      hash = "sha256-+5d81iZt8gu9qiltZg5Wuf5V9KIlxgPzUamGQEYu5OE=";
    };
  };
in
stdenv.mkDerivation {
  pname = "discrawl";
  version = "0.17.0";

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
