{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "repobar-app";
  version = "0.2.0";

  src = fetchzip {
    url = "https://github.com/steipete/RepoBar/releases/download/v0.2.0/RepoBar-0.2.0.zip";
    hash = "sha256-/Sp0DjbiCsmAx+Oh6A3t02TDLiPKUkHkYo8DPgfF1dI=";
    stripRoot = false;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    app_path="$src/RepoBar.app"
    if [ ! -d "$app_path" ]; then
      echo "RepoBar.app not found in $src" >&2
      exit 1
    fi
    cp -R "$app_path" "$out/Applications/RepoBar.app"
    runHook postInstall
  '';

  meta = with lib; {
    description = "RepoBar macOS menu bar app bundle";
    homepage = "https://github.com/steipete/RepoBar";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" ];
  };
}
