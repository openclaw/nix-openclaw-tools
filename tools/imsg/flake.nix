{
  description = "openclaw plugin: imsg";

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
