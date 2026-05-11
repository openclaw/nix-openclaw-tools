{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/Peekaboo/releases/download/v3.1.2/peekaboo-macos-universal.tar.gz";
      hash = "sha256-YnDwfnDbtXJj6pbMKlplVApC/KHDNIG1vPg1fY6BUGM=";
    };
  };
in
stdenv.mkDerivation {
  pname = "peekaboo";
  version = "3.1.2";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp $(find . -type f -name peekaboo | head -1) "$out/bin/peekaboo"
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
