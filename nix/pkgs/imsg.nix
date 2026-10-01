{ lib, stdenv, fetchurl, unzip }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/imsg/releases/download/v0.15.10/imsg-macos.zip";
      hash = "sha256-2IF6u+rzuJlqyTL1qSrAH74XHdLL1qlX5yYwm5eo75w=";
    };
  };
in
stdenv.mkDerivation {
  pname = "imsg";
  version = "0.15.10";

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
