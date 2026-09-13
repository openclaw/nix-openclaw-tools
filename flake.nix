{
  description = "Nix packaging for OpenClaw tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      systems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = lib.genAttrs systems;
      packageSystems = {
        summarize = systems;
        discrawl = systems;
        wacrawl = systems;
        gogcli = systems;
        goplaces = systems;
        camsnap = systems;
        sonoscli = systems;
        peekaboo = [ "aarch64-darwin" ];
        poltergeist = [ "aarch64-darwin" ];
        sag = [ "aarch64-darwin" "x86_64-linux" ];
        imsg = [ "aarch64-darwin" ];
        qmd = [ "aarch64-darwin" "x86_64-linux" ];
      };
    in {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          supported = lib.filterAttrs (_: supportedSystems: lib.elem system supportedSystems) packageSystems;
          packageArgs = {
            summarize = {
              pnpm = pkgs.pnpm_11;
              nodejs = pkgs.nodejs_24;
            };
          };
        in
          lib.mapAttrs (name: _: pkgs.callPackage (./nix/pkgs + "/${name}.nix") (packageArgs.${name} or {})) supported
      );

      checks = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          packages = self.packages.${system};
        in
          packages
          // (lib.optionalAttrs (packages ? qmd) {
            qmd-smoke = pkgs.callPackage ./nix/checks/qmd-smoke.nix {
              qmd = packages.qmd;
            };
          })
          // (lib.optionalAttrs (packages ? imsg && packages ? peekaboo) {
            macos-runtime-assets = pkgs.callPackage ./nix/checks/macos-runtime-assets.nix {
              inherit (packages) imsg peekaboo;
            };
          })
      );
    };
}
