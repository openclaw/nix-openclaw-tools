{ lib
, stdenv
, fetchurl
, nodejs
, pnpm
, python3
, python3Packages
, pkg-config
, makeWrapper
, jq
, git
, pkgs
, zstd
}:

let
  pname = "summarize";
  version = "0.15.1";
  binSources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/summarize/releases/download/v0.15.1/summarize-macos-arm64-v0.15.1.tar.gz";
      hash = "sha256-wEPzO2X5urMCVe1rWd+OtxDB0crHyuD1sBsjbczwvRk=";
    };
  };

  src = fetchurl {
    url = "https://github.com/steipete/summarize/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-i3+rhigG987VqUhBU+DOUNzdbnJs+Cbf7Rs06gG1S1w=";
  };

  pnpmFetchDepsPkg = pkgs.callPackage "${pkgs.path}/pkgs/build-support/node/fetch-pnpm-deps" {
    inherit pnpm;
  };

  pnpmDeps = (pnpmFetchDepsPkg.fetchPnpmDeps {
    pname = pname;
    version = version;
    src = src;
    hash = "sha256-3fsVIIEzf1nG4ik0MrCqhx6jFrdZFfUFoJOr6IeYaOI=";
    fetcherVersion = 3;
  });

  meta = with lib; {
    description = "Link → clean text → summary";
    homepage = "https://github.com/steipete/summarize";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
    mainProgram = "summarize";
  };
in
if stdenv.isLinux then
  stdenv.mkDerivation {
    inherit pname version src meta;

    nativeBuildInputs = [
      nodejs
      pnpm
      python3
      python3Packages.setuptools
      pkg-config
      makeWrapper
      jq
      git
      zstd
    ];

    env = {
      PNPM_IGNORE_PACKAGE_MANAGER_CHECK = "1";
      CI = "1";
      HOME = "/tmp";
      PNPM_HOME = "/tmp/pnpm-home";
      PNPM_CONFIG_HOME = "/tmp/pnpm-config";
      XDG_CACHE_HOME = "/tmp/pnpm-cache";
      NPM_CONFIG_USERCONFIG = "/tmp/pnpm-config/.npmrc";
      npm_config_nodedir = "${lib.getDev nodejs}";
      npm_config_build_from_source = "1";
      PNPM_CONFIG_IGNORE_SCRIPTS = "1";
      PNPM_CONFIG_MANAGE_PACKAGE_MANAGER_VERSIONS = "false";
      PNPM_CONFIG_OFFLINE = "true";
    };

    postPatch = ''
      if [ -f package.json ]; then
        jq 'del(.packageManager)' package.json > package.json.next
        mv package.json.next package.json
      fi
    '';

    buildPhase = ''
      runHook preBuild
      set -euxo pipefail
      echo "summarize: prepare pnpm store $(date -Is)"
      mkdir -p "$HOME" "$PNPM_HOME" "$PNPM_CONFIG_HOME" "$XDG_CACHE_HOME"
      export PNPM_STORE_PATH="$TMPDIR/pnpm-store"
      mkdir -p "$PNPM_STORE_PATH"
      tar --zstd -xf ${pnpmDeps}/pnpm-store.tar.zst -C "$PNPM_STORE_PATH"
      chmod -R +w "$PNPM_STORE_PATH"
      echo "summarize: pnpm install $(date -Is)"
      timeout -k 1m 20m pnpm install --offline --frozen-lockfile --store-dir "$PNPM_STORE_PATH" --ignore-scripts
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

    preFixup = ''
      echo "summarize: fixup start $(date -Is)"
    '';

    postFixup = ''
      echo "summarize: fixup done $(date -Is)"
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
    pname = pname;
    version = version;
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
