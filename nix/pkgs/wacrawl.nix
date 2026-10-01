{ lib, stdenv, fetchurl }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.4.2/wacrawl_0.4.2_darwin_arm64.tar.gz";
      hash = "sha256-2XLydy5Csc709NWXs3qKChzN5HAU3Lq9AKGNgepKBI8=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.4.2/wacrawl_0.4.2_linux_amd64.tar.gz";
      hash = "sha256-/ILud2r9qZ+MFUVj5LdGoybDCQiEgK/75lvaBT2HL7o=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/wacrawl/releases/download/v0.4.2/wacrawl_0.4.2_linux_arm64.tar.gz";
      hash = "sha256-2ZBhZHrRb8fahGYLt1RZMVnqkfF5milv55n2+lg7fiw=";
    };
  };
in
stdenv.mkDerivation {
  pname = "wacrawl";
  version = "0.4.2";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/share/doc/wacrawl"
    cp $(find . -type f -name wacrawl | head -1) "$out/bin/wacrawl"
    chmod 0755 "$out/bin/wacrawl"
    if [ -f LICENSE ]; then
      cp LICENSE "$out/share/doc/wacrawl/"
    fi
    if [ -f README.md ]; then
      cp README.md "$out/share/doc/wacrawl/"
    fi
    runHook postInstall
  '';

  meta = with lib; {
    description = "Read-only local archive and search for WhatsApp Desktop data";
    homepage = "https://github.com/steipete/wacrawl";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "wacrawl";
  };
}
