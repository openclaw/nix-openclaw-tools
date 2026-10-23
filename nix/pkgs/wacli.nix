{ lib, stdenv, fetchurl, autoPatchelfHook }:

let
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/openclaw/wacli/releases/download/v0.25.0/wacli_0.25.0_darwin_arm64.tar.gz";
      hash = "sha256-7ekXCsZhyL75xf1EmylhEwHAtjlHqf+tgY3Z7JgaR6E=";
    };
    "x86_64-linux" = {
      url = "https://github.com/openclaw/wacli/releases/download/v0.25.0/wacli_0.25.0_linux_amd64.tar.gz";
      hash = "sha256-nL7lt3ebVnC9Ftz4/toilKEeSsyAHZg375zRpmGfxzw=";
    };
    "aarch64-linux" = {
      url = "https://github.com/openclaw/wacli/releases/download/v0.25.0/wacli_0.25.0_linux_arm64.tar.gz";
      hash = "sha256-koLD6r5KRF2wV6weN5sUZIu8y5TXtIbwuWDtjd5j/4I=";
    };
  };
in
stdenv.mkDerivation {
  pname = "wacli";
  version = "0.25.0";

  # Upstream builds ./cmd/wacli with Go 1.27+, CGO_ENABLED=1 and sqlite_fts5.
  src = fetchurl sources.${stdenv.hostPlatform.system};

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.libc ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 wacli "$out/bin/wacli"
    install -Dm644 LICENSE "$out/share/doc/wacli/LICENSE"
    install -Dm644 README.md "$out/share/doc/wacli/README.md"
    runHook postInstall
  '';

  meta = with lib; {
    description = "WhatsApp linked-device CLI for synchronization, search, and sending";
    homepage = "https://github.com/openclaw/wacli";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "wacli";
  };
}
