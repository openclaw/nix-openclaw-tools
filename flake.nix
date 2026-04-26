{
  description = "Nix packaging for steipete tools (clawdbot)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      systems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: lib.genAttrs systems (system: f system);
      packageSystems = {
        summarize = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
        discrawl = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
        gogcli = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
        goplaces = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
        camsnap = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
        sonoscli = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
        bird = [ "aarch64-darwin" ];
        peekaboo = [ "aarch64-darwin" ];
        poltergeist = [ "aarch64-darwin" ];
        sag = [ "aarch64-darwin" "x86_64-linux" ];
        imsg = [ "aarch64-darwin" ];
      };
    in {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          supports = name: lib.elem system packageSystems.${name};
        in
          (lib.optionalAttrs (supports "summarize") {
            summarize = pkgs.callPackage ./nix/pkgs/summarize.nix {
              pkgs = pkgs;
              pnpm = if pkgs ? pnpm_10 then pkgs.pnpm_10 else pkgs.pnpm;
              nodejs = if pkgs ? nodejs_22 then pkgs.nodejs_22 else pkgs.nodejs;
            };
          })
          // (lib.optionalAttrs (supports "discrawl") {
            discrawl = pkgs.callPackage ./nix/pkgs/discrawl.nix {};
          })
          // (lib.optionalAttrs (supports "gogcli") {
            gogcli = pkgs.callPackage ./nix/pkgs/gogcli.nix {};
          })
          // (lib.optionalAttrs (supports "goplaces") {
            goplaces = pkgs.callPackage ./nix/pkgs/goplaces.nix {};
          })
          // (lib.optionalAttrs (supports "camsnap") {
            camsnap = pkgs.callPackage ./nix/pkgs/camsnap.nix {};
          })
          // (lib.optionalAttrs (supports "sonoscli") {
            sonoscli = pkgs.callPackage ./nix/pkgs/sonoscli.nix {};
          })
          // (lib.optionalAttrs (supports "bird") {
            bird = pkgs.callPackage ./nix/pkgs/bird.nix {};
          })
          // (lib.optionalAttrs (supports "peekaboo") {
            peekaboo = pkgs.callPackage ./nix/pkgs/peekaboo.nix {};
          })
          // (lib.optionalAttrs (supports "poltergeist") {
            poltergeist = pkgs.callPackage ./nix/pkgs/poltergeist.nix {};
          })
          // (lib.optionalAttrs (supports "sag") {
            sag = pkgs.callPackage ./nix/pkgs/sag.nix {};
          })
          // (lib.optionalAttrs (supports "imsg") {
            imsg = pkgs.callPackage ./nix/pkgs/imsg.nix {};
          })
      );

      checks = forAllSystems (system: self.packages.${system});
    };
}
