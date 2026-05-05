{
  description = "openclaw plugin: sonoscli";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=16c7794d0a28b5a37904d55bcca36003b9109aaa&narHash=sha256-fFUnEYMla8b7UKjijLnMe%2BoVFOz6HjijGGNS1l7dYaQ%3D";
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
