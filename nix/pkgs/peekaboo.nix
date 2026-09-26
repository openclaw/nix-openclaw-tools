{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/Peekaboo/releases/download/v4.6.0/peekaboo-macos-arm64.tar.gz";
      hash = "sha256-v4ERL+Vp4aLLxmZuattFqx/RGh8aXBcIUi0a/0xSaRU=";
    };
  };
in
stdenv.mkDerivation {
  pname = "peekaboo";
  version = "4.6.0";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    binary="$(find . -type f -name peekaboo -print -quit)"
    cp "$binary" "$out/bin/peekaboo"
    binaryDir="$(dirname "$binary")"
    for companion in "$binaryDir"/*.bundle "$binaryDir"/*.dylib; do
      if [ -e "$companion" ]; then
        cp -R "$companion" "$out/bin/"
      fi
    done
    chmod 0755 "$out/bin/peekaboo"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Lightning-fast macOS screenshots & AI vision analysis";
    homepage = "https://github.com/openclaw/Peekaboo";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "peekaboo";
  };
}
