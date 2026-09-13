{
  description = "openclaw plugin: discrawl";

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
