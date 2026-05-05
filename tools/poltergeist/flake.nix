{
  description = "openclaw plugin: poltergeist";

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
