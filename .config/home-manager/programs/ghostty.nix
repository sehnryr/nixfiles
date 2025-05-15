{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.modules.ghostty;
  fonts = config.modules.fonts;
  nushell = config.modules.nushell;
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
      (lib.mkIf fonts.enable {
        settings = {
          font-family = fonts.monospace.family;
          font-size = fonts.monospace.size;
        };
      })
      (lib.mkIf nushell.enable {
        settings = {
          command = "${nushell.package}/bin/nu";
        };
      })
    ];
  };
}
