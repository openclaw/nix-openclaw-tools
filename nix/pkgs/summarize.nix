{ lib
, stdenv
, fetchurl
, nodejs
, pnpm
, fetchPnpmDeps
, pnpmConfigHook
, python3
, python3Packages
, pkg-config
, makeWrapper
, git
}:

let
  pname = "summarize";
  version = "0.21.15";
  binSources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/summarize/releases/download/v0.21.15/summarize-macos-arm64-v0.21.15.tar.gz";
      hash = "sha256-y7TWBD/j4IrB9wAdd7m4yAGdPFxI5wD9MK79n1lU7mw=";
    };
  };

  src = fetchurl {
    url = "https://github.com/steipete/summarize/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-HJQl+ke0Um6q58r//vfnW3RBPUB9G4hIj69uxO3KAy0=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit pname version src pnpm;
    hash = "sha256-wWp0YZWOBf6CX4Og6eNoRCm019y3T78EmFuT8nfEplE=";
    fetcherVersion = 4;
  };

  meta = with lib; {
    description = "Link → clean text → summary";
    homepage = "https://github.com/steipete/summarize";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
    mainProgram = "summarize";
  };
in
if stdenv.hostPlatform.isLinux then
  stdenv.mkDerivation {
    inherit pname version src meta pnpmDeps;

    nativeBuildInputs = [
      nodejs
      pnpm
      pnpmConfigHook
      python3
      python3Packages.setuptools
      pkg-config
      makeWrapper
      git
    ];

    # makeWrapper completes the runtime package during install. Generic fixup
    # would shell-classify the entire vendored JS workspace for each hook.
    dontFixup = true;

    env = {
      CI = "1";
      npm_config_nodedir = "${lib.getDev nodejs}";
      npm_config_build_from_source = "1";
    };

    buildPhase = ''
      runHook preBuild
      set -euxo pipefail
      export PATH="$PWD/node_modules/.bin:$PATH"
      rm -rf dist packages/core/dist
      echo "summarize: build core $(date -Is)"
      timeout -k 1m 10m bash -c 'cd packages/core && tsc -p tsconfig.build.json'
      echo "summarize: build cli $(date -Is)"
      timeout -k 1m 10m tsc -p tsconfig.build.json
      echo "summarize: build bundle $(date -Is)"
      timeout -k 1m 10m node scripts/build-cli.mjs
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/libexec" "$out/libexec/packages" "$out/libexec/apps" "$out/bin"
      cp -r dist node_modules "$out/libexec/"
      find "$out/libexec/node_modules" -name ".pnpm-workspace-state-v1.json" -delete
      cp -r packages/core "$out/libexec/packages/"
      cp -r apps/chrome-extension "$out/libexec/apps/"
      chmod 0755 "$out/libexec/dist/cli.js"
      makeWrapper "${nodejs}/bin/node" "$out/bin/summarize" \
        --add-flags "$out/libexec/dist/cli.js" \
        --set-default SUMMARIZE_VERSION "${version}"
      runHook postInstall
    '';
  }
else
  stdenv.mkDerivation {
    inherit pname version;
    src = fetchurl binSources.${stdenv.hostPlatform.system};

    dontConfigure = true;
    dontBuild = true;

    unpackPhase = ''
      tar -xzf "$src"
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      cp summarize "$out/bin/summarize"
      chmod 0755 "$out/bin/summarize"
      runHook postInstall
    '';

    inherit meta;
  }
