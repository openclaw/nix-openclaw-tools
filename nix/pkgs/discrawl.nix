{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/discrawl/releases/download/v0.6.0/discrawl_0.6.0_darwin_arm64.tar.gz";
      hash = "sha256-VAGD2mmbZP3pxBgtzg9n3DE89NDLKD5iUIVMbJYwaOo=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/discrawl/releases/download/v0.6.0/discrawl_0.6.0_linux_amd64.tar.gz";
      hash = "sha256-KQlpw/I1asBK4+3IlbCiO76+ysJIMVSSuwqrr9UG190=";
    };
    "aarch64-linux" = {
      url = "https://github.com/steipete/discrawl/releases/download/v0.6.0/discrawl_0.6.0_linux_arm64.tar.gz";
      hash = "sha256-2uRQonrM4THiSyNUir9bgOyaTWHbPv4brIPCNW4yU4s=";
    };
  };
in
stdenv.mkDerivation {
  pname = "discrawl";
  version = "0.6.0";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/share/doc/discrawl"
    cp $(find . -type f -name discrawl | head -1) "$out/bin/discrawl"
    chmod 0755 "$out/bin/discrawl"
    if [ -f LICENSE ]; then
      cp LICENSE "$out/share/doc/discrawl/"
    fi
    if [ -f README.md ]; then
      cp README.md "$out/share/doc/discrawl/"
    fi
    runHook postInstall
  '';

  meta = with lib; {
    description = "Mirror Discord into SQLite and search server history locally";
    homepage = "https://github.com/steipete/discrawl";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "discrawl";
  };
}
