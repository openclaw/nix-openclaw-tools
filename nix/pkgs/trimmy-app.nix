{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "trimmy-app";
  version = "0.8.0";

  src = fetchzip {
    url = "https://github.com/steipete/Trimmy/releases/download/v0.8.0/Trimmy-0.8.0.zip";
    hash = "sha256-1uMz6mznUN1UMkPRgodVM3LtuGlsG8kWCyehRZ9GW8s=";
    stripRoot = false;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    app_path="$src/Trimmy.app"
    if [ ! -d "$app_path" ]; then
      echo "Trimmy.app not found in $src" >&2
      exit 1
    fi
    cp -R "$app_path" "$out/Applications/Trimmy.app"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Trimmy macOS menu bar app bundle";
    homepage = "https://github.com/steipete/Trimmy";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" ];
  };
}
