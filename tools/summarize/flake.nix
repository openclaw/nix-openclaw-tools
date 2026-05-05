{
  description = "openclaw plugin: summarize";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=16c7794d0a28b5a37904d55bcca36003b9109aaa&narHash=sha256-fFUnEYMla8b7UKjijLnMe%2BoVFOz6HjijGGNS1l7dYaQ%3D";
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
