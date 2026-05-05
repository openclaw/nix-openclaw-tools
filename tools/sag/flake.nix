{
  description = "openclaw plugin: sag";

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
          sag = packagesForSystem.sag or null;
        in
          if sag == null then null else {
            name = "sag";
            skills = [ ./skills/sag ];
            packages = [ sag ];
            needs = {
              stateDirs = [];
              requiredEnv = [];
            };
          };
    in {
      packages = lib.genAttrs systems (system:
        let
          sag = (root.packages.${system} or {}).sag or null;
        in
          if sag == null then {}
          else { sag = sag; }
      );

      openclawPlugin = pluginFor;
    };
}
