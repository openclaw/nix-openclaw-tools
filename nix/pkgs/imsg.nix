{ lib, stdenv, fetchurl, unzip }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/imsg/releases/download/v0.20.0/imsg-macos.zip";
      hash = "sha256-k3B5NIXLn5rgYChr6XjH6XHb15lhMBf93NkT0TZty3U=";
    };
  };
in
stdenv.mkDerivation {
  pname = "imsg";
  version = "0.20.0";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  nativeBuildInputs = [ unzip ];
  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    unzip -q "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp imsg "$out/bin/imsg"
    chmod 0755 "$out/bin/imsg"
    for companion in *.bundle *.dylib; do
      if [ -e "$companion" ]; then
        cp -R "$companion" "$out/bin/"
      fi
    done
    runHook postInstall
  '';

  meta = with lib; {
    description = "Send and read iMessage / SMS from the terminal";
    homepage = "https://github.com/openclaw/imsg";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "imsg";
  };
}
