{
  description = "openclaw plugin: imsg";

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
          imsg = packagesForSystem.imsg or null;
        in
          if imsg == null then null else {
            name = "imsg";
            skills = [ ./skills/imsg ];
            packages = [ imsg ];
            needs = {
              stateDirs = [];
              requiredEnv = [];
            };
          };
    in {
      packages = lib.genAttrs systems (system:
        let
          imsg = (root.packages.${system} or {}).imsg or null;
        in
          if imsg == null then {}
          else { imsg = imsg; }
      );

      openclawPlugin = pluginFor;
    };
}
