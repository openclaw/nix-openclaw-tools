{
  description = "openclaw plugin: gogcli";

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
