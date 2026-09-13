{
  description = "openclaw plugin: poltergeist";

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
          poltergeist = packagesForSystem.poltergeist or null;
        in
          if poltergeist == null then null else {
            name = "poltergeist";
            skills = [ ./skills/poltergeist ];
            packages = [ poltergeist ];
            needs = {
              stateDirs = [];
              requiredEnv = [];
            };
          };
    in {
      packages = lib.genAttrs systems (system:
        let
          poltergeist = (root.packages.${system} or {}).poltergeist or null;
        in
          if poltergeist == null then {}
          else { poltergeist = poltergeist; }
      );

      openclawPlugin = pluginFor;
    };
}
