{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.modules.ghostty;
in
{
  options.modules.ghostty = {
    enable = lib.mkEnableOption "";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.ghostty;
    };
    theme = {
      light = lib.mkOption {
        type = lib.types.str;
        default = "Builtin Tango Light";
      };
      dark = lib.mkOption {
        type = lib.types.str;
        default = "Ghostty Default StyleDark";
      };
    };
    fonts = {
      monospace = {
        family = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        size = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
        };
      };
    };
    enableNushellIntegration = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = lib.mkMerge [
      {
        enable = true;
        package = cfg.package;
        settings = {
          theme = "light:${cfg.theme.light},dark:${cfg.theme.dark}";
          resize-overlay = "never";
        };
      }
      (lib.mkIf (cfg.fonts.monospace.family != null) {
        settings = {
          font-family = cfg.fonts.monospace.family;
        };
      })
      (lib.mkIf (cfg.fonts.monospace.size != null) {
        settings = {
          font-size = cfg.fonts.monospace.size;
        };
      })
      (lib.mkIf cfg.enableNushellIntegration {
        settings = {
          command = "nu";
        };
      })
    ];
  };
}
