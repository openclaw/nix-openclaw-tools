{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/poltergeist/releases/download/v2.1.12/poltergeist-macos-universal-v2.1.12.tar.gz";
      hash = "sha256-7P/p9DeX5zUuHtp2yxuGLZQZRREaXqaAzrAR4Rzsmm0=";
    };
  };
in
stdenv.mkDerivation {
  pname = "poltergeist";
  version = "2.1.12";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    cp poltergeist "$out/bin/poltergeist"
    cp polter "$out/bin/polter"
    chmod 0755 "$out/bin/poltergeist" "$out/bin/polter"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Universal file watcher with auto-rebuild for any language or build system";
    homepage = "https://github.com/steipete/poltergeist";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "poltergeist";
  };
}
