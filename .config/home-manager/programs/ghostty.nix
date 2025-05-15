{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.ghostty;
  fonts = config.modules.fonts;
in
{
  options.modules.ghostty = {
    enable = lib.mkEnableOption "";
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
        package = config.lib.nixGL.wrap pkgs.ghostty;
        settings = {
          theme = "light:${cfg.theme.light},dark:${cfg.theme.dark}";
          # TODO: set conditionally when nushell is enabled
          command = "${pkgs.nushell}/bin/nu";
          resize-overlay = "never";
        };
      }
      (lib.mkIf fonts.enable {
        settings = {
          font-family = fonts.monospace.family;
          font-size = fonts.monospace.size;
        };
      })
    ];
  };
}
