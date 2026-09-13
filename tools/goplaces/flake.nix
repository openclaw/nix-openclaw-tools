{
  description = "openclaw plugin: goplaces";

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
          goplaces = packagesForSystem.goplaces or null;
        in
          if goplaces == null then null else {
            name = "goplaces";
            skills = [ ./skills/goplaces ];
            packages = [ goplaces ];
            needs = {
              stateDirs = [];
              requiredEnv = [];
            };
          };
    in {
      packages = lib.genAttrs systems (system:
        let
          goplaces = (root.packages.${system} or {}).goplaces or null;
        in
          if goplaces == null then {}
          else { goplaces = goplaces; }
      );

      openclawPlugin = pluginFor;
    };
}
