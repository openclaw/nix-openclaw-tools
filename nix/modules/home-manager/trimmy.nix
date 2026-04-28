{ self }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.programs.trimmy;
  system = pkgs.stdenv.hostPlatform.system;
  defaultPackage =
    if self.packages ? ${system} && self.packages.${system} ? trimmy-app then
      self.packages.${system}.trimmy-app
    else
      null;
in
{
  options.programs.trimmy = {
    enable = mkEnableOption "Trimmy macOS menu bar app";

    package = mkOption {
      type = types.nullOr types.package;
      default = defaultPackage;
      defaultText = lib.literalExpression "inputs.nix-steipete-tools.packages.\${pkgs.system}.trimmy-app";
      description = "Trimmy app package.";
    };

    launchd = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Configure a launchd agent to manage the Trimmy process.

          Trimmy can also manage launch-at-login from inside the app. Enable this
          option when you want Home Manager and launchd to own startup instead.
        '';
      };

      keepAlive = mkOption {
        type = types.bool;
        default = false;
        description = "Whether launchd should restart Trimmy after it exits.";
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
        description = "Environment variables passed to the Trimmy launchd agent.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "programs.trimmy" pkgs lib.platforms.darwin)
      {
        assertion = cfg.package != null;
        message = "programs.trimmy.package must be set on this platform.";
      }
      {
        assertion = !cfg.launchd.enable || config.launchd.enable;
        message = "programs.trimmy.launchd.enable requires launchd.enable.";
      }
    ];

    home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

    launchd.agents.trimmy = mkIf cfg.launchd.enable {
      enable = true;
      config = {
        ProgramArguments = [ "${cfg.package}/Applications/Trimmy.app/Contents/MacOS/Trimmy" ];
        ProcessType = "Interactive";
        RunAtLoad = true;
        KeepAlive = cfg.launchd.keepAlive;
        EnvironmentVariables = cfg.launchd.environmentVariables;
      };
    };
  };
}
