{
  description = "openclaw plugin: discrawl";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=16c7794d0a28b5a37904d55bcca36003b9109aaa&narHash=sha256-fFUnEYMla8b7UKjijLnMe%2BoVFOz6HjijGGNS1l7dYaQ%3D";
    root.url = "path:../..";
  };

  outputs = { self, nixpkgs, root }:
    let
      lib = nixpkgs.lib;
      systems = builtins.attrNames root.packages;
      pluginFor = system:
        let
          packagesForSystem = root.packages.${system} or {};
          discrawl = packagesForSystem.discrawl or null;
        in
          if discrawl == null then null else {
            name = "discrawl";
            skills = [ ./skills/discrawl ];
            packages = [ discrawl ];
            needs = {
              stateDirs = [ ".discrawl" ];
              requiredEnv = [ ];
            };
          };
    in {
      packages = lib.genAttrs systems (system:
        let
          discrawl = (root.packages.${system} or {}).discrawl or null;
        in
          if discrawl == null then {}
          else { discrawl = discrawl; }
      );

      openclawPlugin = pluginFor;
    };
}
