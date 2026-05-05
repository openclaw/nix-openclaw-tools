{
  description = "openclaw plugin: gogcli";

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
          gogcli = packagesForSystem.gogcli or null;
        in
          if gogcli == null then null else {
            name = "gogcli";
            skills = [ ./skills/gog ];
            packages = [ gogcli ];
            needs = {
              stateDirs = [];
              requiredEnv = [];
            };
          };
    in {
      packages = lib.genAttrs systems (system:
        let
          gogcli = (root.packages.${system} or {}).gogcli or null;
        in
          if gogcli == null then {}
          else { gogcli = gogcli; }
      );

      openclawPlugin = pluginFor;
    };
}
