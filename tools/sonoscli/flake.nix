{
  description = "openclaw plugin: sonoscli";

  inputs = {
    nixpkgs.follows = "root/nixpkgs";
    root.url = "../..";
  };

  outputs = { self, nixpkgs, root }:
    let
      lib = nixpkgs.lib;
      systems = builtins.attrNames root.packages;
      pluginFor = system:
        let
          packagesForSystem = root.packages.${system} or {};
          sonoscli = packagesForSystem.sonoscli or null;
        in
          if sonoscli == null then null else {
            name = "sonoscli";
            skills = [ ./skills/sonoscli ];
            packages = [ sonoscli ];
            needs = {
              stateDirs = [];
              requiredEnv = [];
            };
          };
    in {
      packages = lib.genAttrs systems (system:
        let
          sonoscli = (root.packages.${system} or {}).sonoscli or null;
        in
          if sonoscli == null then {}
          else { sonoscli = sonoscli; }
      );

      openclawPlugin = pluginFor;
    };
}
