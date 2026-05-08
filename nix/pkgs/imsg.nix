{ lib, stdenv, fetchurl, unzip }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/imsg/releases/download/v0.8.0/imsg-macos.zip";
      hash = "sha256-CO2pbs85AbN8FcKdai22BCElRiYJLcj9jf5sXUj1lE8=";
    };
  };
in
stdenv.mkDerivation {
  pname = "imsg";
  version = "0.8.0";

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
    if [ -f PhoneNumberKit_PhoneNumberKit.bundle ]; then
      cp -R PhoneNumberKit_PhoneNumberKit.bundle "$out/bin/"
    fi
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
