{
  description = "openclaw plugin: qmd";

  inputs = {
    nixpkgs.follows = "root/nixpkgs";
    root.url = "../..";
  };

  outputs =
    {
      self,
      nixpkgs,
      root,
    }:
    let
      lib = nixpkgs.lib;
      systems = builtins.attrNames root.packages;
      pluginFor =
        system:
        let
          packagesForSystem = root.packages.${system} or { };
          qmd = packagesForSystem.qmd or null;
        in
        if qmd == null then
          null
        else
          {
            name = "qmd";
            skills = [ ./skills/qmd ];
            packages = [ qmd ];
            needs = {
              stateDirs = [ ".local/share/qmd" ];
              requiredEnv = [ ];
            };
          };
    in
    {
      packages = lib.genAttrs systems (
        system:
        let
          qmd = (root.packages.${system} or { }).qmd or null;
        in
        if qmd == null then { } else { qmd = qmd; }
      );

      openclawPlugin = pluginFor;
    };
}
