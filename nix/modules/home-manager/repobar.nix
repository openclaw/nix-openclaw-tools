{ self }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.programs.repobar;
  system = pkgs.stdenv.hostPlatform.system;
  defaultPackage =
    if self.packages ? ${system} && self.packages.${system} ? repobar-app then
      self.packages.${system}.repobar-app
    else
      null;
in
{
  options.programs.repobar = {
    enable = mkEnableOption "RepoBar macOS menu bar app";

    package = mkOption {
      type = types.nullOr types.package;
      default = defaultPackage;
      defaultText = lib.literalExpression "inputs.nix-steipete-tools.packages.\${pkgs.system}.repobar-app";
      description = "RepoBar app package.";
    };

    launchd = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Configure a launchd agent to manage the RepoBar process.

          RepoBar can also manage launch-at-login from inside the app. Enable this
          option when you want Home Manager and launchd to own startup instead.
        '';
      };

      keepAlive = mkOption {
        type = types.bool;
        default = false;
        description = "Whether launchd should restart RepoBar after it exits.";
      };

      environmentVariables = mkOption {
        type = types.attrsOf types.str;
        default = {
          PATH = "${config.home.profileDirectory}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        };
        defaultText = lib.literalExpression ''
          {
            PATH = "\${config.home.profileDirectory}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
          }
        '';
        description = "Environment variables passed to the RepoBar launchd agent.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "programs.repobar" pkgs lib.platforms.darwin)
      {
        assertion = cfg.package != null;
        message = "programs.repobar.package must be set on this platform.";
      }
      {
        assertion = !cfg.launchd.enable || config.launchd.enable;
        message = "programs.repobar.launchd.enable requires launchd.enable.";
      }
    ];

    home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

    launchd.agents.repobar = mkIf cfg.launchd.enable {
      enable = true;
      config = {
        ProgramArguments = [ "${cfg.package}/Applications/RepoBar.app/Contents/MacOS/RepoBar" ];
        ProcessType = "Interactive";
        RunAtLoad = true;
        KeepAlive = cfg.launchd.keepAlive;
        EnvironmentVariables = cfg.launchd.environmentVariables;
      };
    };
  };
}
