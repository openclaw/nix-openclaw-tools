{ lib, stdenv, fetchurl, ffmpeg, makeWrapper }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/camsnap/releases/download/v0.6.2/camsnap_0.6.2_darwin_arm64.tar.gz";
      hash = "sha256-oxcKFGgsdWCUE96S4Srt8xue8wSaXTeepWh/k95BjmA=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/camsnap/releases/download/v0.6.2/camsnap_0.6.2_linux_amd64.tar.gz";
      hash = "sha256-LHEdhlQVm4Wzwew3xDBbeVpcb1w+IUL4qZyjCBbcs10=";
    };
    "aarch64-linux" = {
      url = "https://github.com/steipete/camsnap/releases/download/v0.6.2/camsnap_0.6.2_linux_arm64.tar.gz";
      hash = "sha256-HS9GRXJWrU2DBmKLX/uagrxOOfJcncYAE5TX2AunJbo=";
    };
  };
in
stdenv.mkDerivation {
  pname = "camsnap";
  version = "0.6.2";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  nativeBuildInputs = [ makeWrapper ];
  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/share/doc/camsnap"
    cp $(find . -type f -name camsnap | head -1) "$out/bin/camsnap"
    chmod 0755 "$out/bin/camsnap"
    wrapProgram "$out/bin/camsnap" --prefix PATH : "${lib.makeBinPath [ ffmpeg ]}"
    if [ -f LICENSE ]; then
      cp LICENSE "$out/share/doc/camsnap/"
    fi
    if [ -f README.md ]; then
      cp README.md "$out/share/doc/camsnap/"
    fi
    runHook postInstall
  '';

  meta = with lib; {
    description = "One command to grab frames, clips, or motion alerts from RTSP/ONVIF cams";
    homepage = "https://github.com/steipete/camsnap";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "camsnap";
  };
}
