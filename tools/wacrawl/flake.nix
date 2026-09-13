{
  description = "openclaw plugin: wacrawl";

  inputs = {
    nixpkgs.follows = "root/nixpkgs";
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
