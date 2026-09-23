{ lib, stdenv, fetchurl, ffmpeg, makeWrapper }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/camsnap/releases/download/v0.5.2/camsnap_0.5.2_darwin_arm64.tar.gz";
      hash = "sha256-eYnJeFDxmvqyrEzSIdS0lHHp/ONBBf+fJvja2vWIBU8=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/camsnap/releases/download/v0.5.2/camsnap_0.5.2_linux_amd64.tar.gz";
      hash = "sha256-eaEualRuH8RpWCJebyf4L5lUA4+7LibnzAo7AsRSIjc=";
    };
    "aarch64-linux" = {
      url = "https://github.com/steipete/camsnap/releases/download/v0.5.2/camsnap_0.5.2_linux_arm64.tar.gz";
      hash = "sha256-QtSj8xoWbtHbdXq2cCd7yhAnrl+m4rAv//sES1r6sU4=";
    };
  };
in
stdenv.mkDerivation {
  pname = "camsnap";
  version = "0.5.2";

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
