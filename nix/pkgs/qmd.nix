{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
  makeWrapper,
  nodejs,
  node-gyp,
  python3,
  sqlite,
  darwin,
  xcbuild,
}:

let
  pname = "qmd";
  version = "2.5.3";

  src = fetchFromGitHub {
    owner = "tobi";
    repo = "qmd";
    rev = "v${version}";
    hash = "sha256-bFk078qQ8Ha/1na+r5ka6yNPI/Pealh0Rk6hJxKBwNs=";
  };

  nodeModulesHashes = {
    "aarch64-darwin" = "sha256-gDyJ5boyH44SeXlKo+W4G36GSUejyXP5PFvW+dFS1Mk=";
    "x86_64-linux" = "sha256-sVXoNWIcx1RYRtRWB4F2j7x8/cabFBKq+plFhPU7tBc=";
  };

  system = stdenv.hostPlatform.system;

  nodeModules = stdenvNoCC.mkDerivation {
    pname = "qmd-node-modules";
    inherit version src;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND"
      "SOCKS_SERVER"
    ];

    nativeBuildInputs = [ bun ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild
      export HOME="$(mktemp -d)"
      bun install \
        --backend copyfile \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress \
        --production
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -R node_modules "$out/"
      runHook postInstall
    '';

    dontFixup = true;

    outputHash = nodeModulesHashes.${system};
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    bun
    makeWrapper
    nodejs
    node-gyp
    python3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.cctools
    xcbuild
  ];

  buildInputs = [ sqlite ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    export HOME="$(mktemp -d)"

    cp -R ${nodeModules}/node_modules ./
    chmod -R u+w node_modules

    (cd node_modules/better-sqlite3 && node-gyp rebuild --release)
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/lib/qmd"

    cp -r node_modules src package.json "$out/lib/qmd/"

    makeWrapper ${bun}/bin/bun "$out/bin/qmd" \
      --add-flags "$out/lib/qmd/src/cli/qmd.ts" \
      --set DYLD_LIBRARY_PATH "${sqlite.out}/lib" \
      --set LD_LIBRARY_PATH "${sqlite.out}/lib"
    runHook postInstall
  '';

  meta = with lib; {
    description = "On-device hybrid search for markdown knowledge bases";
    homepage = "https://github.com/tobi/qmd";
    license = licenses.mit;
    platforms = builtins.attrNames nodeModulesHashes;
    mainProgram = "qmd";
  };
}
