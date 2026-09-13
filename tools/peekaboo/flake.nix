{
  description = "openclaw plugin: peekaboo";

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
          peekaboo = packagesForSystem.peekaboo or null;
        in
          if peekaboo == null then null else {
            name = "peekaboo";
            skills = [ ./skills/peekaboo ];
            packages = [ peekaboo ];
            needs = {
              stateDirs = [];
              requiredEnv = [];
            };
          };
    in {
      packages = lib.genAttrs systems (system:
        let
          peekaboo = (root.packages.${system} or {}).peekaboo or null;
        in
          if peekaboo == null then {}
          else { peekaboo = peekaboo; }
      );

      openclawPlugin = pluginFor;
    };
}
