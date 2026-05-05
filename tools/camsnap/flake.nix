{
  description = "openclaw plugin: camsnap";

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
