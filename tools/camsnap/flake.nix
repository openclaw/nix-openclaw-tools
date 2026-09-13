{
  description = "openclaw plugin: camsnap";

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
          camsnap = packagesForSystem.camsnap or null;
        in
          if camsnap == null then null else {
            name = "camsnap";
            skills = [ ./skills/camsnap ];
            packages = [ camsnap ];
            needs = {
              stateDirs = [];
              requiredEnv = [];
            };
          };
    in {
      packages = lib.genAttrs systems (system:
        let
          camsnap = (root.packages.${system} or {}).camsnap or null;
        in
          if camsnap == null then {}
          else { camsnap = camsnap; }
      );

      openclawPlugin = pluginFor;
    };
}
