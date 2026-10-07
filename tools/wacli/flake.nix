{
  description = "openclaw plugin: wacli";

  inputs = {
    nixpkgs.follows = "root/nixpkgs";
    root.url = "path:../..";
  };

  outputs = { self, nixpkgs, root }:
    let
      lib = nixpkgs.lib;
      systems = builtins.attrNames root.packages;
      pluginFor = system:
        let
          packagesForSystem = root.packages.${system} or {};
          wacli = packagesForSystem.wacli or null;
        in
          if wacli == null then null else {
            name = "wacli";
            skills = [ ./skills/wacli ];
            packages = [ wacli ];
            needs = {
              stateDirs = [ (if lib.hasSuffix "-linux" system then ".local/state/wacli" else ".wacli") ];
              requiredEnv = [ ];
            };
          };
    in {
      packages = lib.genAttrs systems (system:
        let
          wacli = (root.packages.${system} or {}).wacli or null;
        in
          if wacli == null then {}
          else { wacli = wacli; }
      );

      openclawPlugin = pluginFor;
    };
}
