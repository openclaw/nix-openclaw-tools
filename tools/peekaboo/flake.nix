{
  description = "openclaw plugin: peekaboo";

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
