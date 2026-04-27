{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "codexbar-app";
  version = "0.23";

  src = fetchzip {
    url = "https://github.com/steipete/CodexBar/releases/download/v0.23/CodexBar-0.23.zip";
    hash = "sha256-4LtZZzoP9tofNhy8jVkaopE+aivn0PRBEeJBGpDnbE8=";
    stripRoot = false;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    app_path="$(find "$src" -maxdepth 2 -name 'CodexBar.app' -print -quit)"
    if [ -z "$app_path" ]; then
      echo "CodexBar.app not found in $src" >&2
      exit 1
    fi
    cp -R "$app_path" "$out/Applications/CodexBar.app"
    runHook postInstall
  '';

  meta = with lib; {
    description = "CodexBar macOS menu bar app bundle";
    homepage = "https://github.com/steipete/CodexBar";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" ];
  };
}
