{
  description = "openclaw plugin: wacrawl";

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
          wacrawl = packagesForSystem.wacrawl or null;
        in
          if wacrawl == null then null else {
            name = "wacrawl";
            skills = [ ./skills/wacrawl ];
            packages = [ wacrawl ];
            needs = {
              stateDirs = [ ".wacrawl" ];
              requiredEnv = [ ];
            };
          };
    in {
      packages = lib.genAttrs systems (system:
        let
          wacrawl = (root.packages.${system} or {}).wacrawl or null;
        in
          if wacrawl == null then {}
          else { wacrawl = wacrawl; }
      );

      openclawPlugin = pluginFor;
    };
}
