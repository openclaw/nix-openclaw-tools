{
  description = "openclaw plugin: sag";

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
