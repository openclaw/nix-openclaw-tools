{
  description = "openclaw plugin: summarize";

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
          summarize = packagesForSystem.summarize or null;
        in
          if summarize == null then null else {
            name = "summarize";
            skills = [ ./skills/summarize ];
            packages = [ summarize ];
            needs = {
              stateDirs = [];
              requiredEnv = [];
            };
          };
    in {
      packages = lib.genAttrs systems (system:
        let
          summarize = (root.packages.${system} or {}).summarize or null;
        in
          if summarize == null then {}
          else { summarize = summarize; }
      );

      openclawPlugin = pluginFor;
    };
}
