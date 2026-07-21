{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.11.8/discrawl_0.11.8_darwin_arm64.tar.gz";
      hash = "sha256-kAcUZ6uG6WdYU1sF1oia+4CBZA0/HReR6VNx8iwfAck=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.11.8/discrawl_0.11.8_linux_amd64.tar.gz";
      hash = "sha256-bNXkrOzjc9KaFnuxVQJfXVyfW+bomX8XZa01XaYkizw=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/discrawl/releases/download/v0.11.8/discrawl_0.11.8_linux_arm64.tar.gz";
      hash = "sha256-yTJ1I1z/y2RI+x/7rKSwhegV5JN09edE0PHAqNJnTvQ=";
    };
  };
in
stdenv.mkDerivation {
  pname = "discrawl";
  version = "0.11.8";

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
