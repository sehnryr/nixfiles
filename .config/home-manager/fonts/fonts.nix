{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.fonts;
  mkFont =
    {
      package,
      family,
      size ? 11,
    }:
    {
      package = lib.mkOption {
        type = lib.types.package;
        default = package;
      };
      family = lib.mkOption {
        type = lib.types.str;
        default = family;
      };
      size = lib.mkOption {
        type = lib.types.int;
        default = size;
      };
    };
  mkFontSpecial =
    {
      package,
      family,
    }:
    {
      package = lib.mkOption {
        type = lib.types.package;
        default = package;
      };
      family = lib.mkOption {
        type = lib.types.str;
        default = family;
      };
    };
in
{
  options.modules.fonts = {
    enable = lib.mkEnableOption "";
    default = mkFont {
      package = pkgs.cantarell-fonts;
      family = "Cantarell";
      size = 11;
    };
    monospace = mkFont {
      package = pkgs.maple-mono.NF;
      family = "Maple Mono NF";
      size = 10;
    };
    emoji = mkFontSpecial {
      package = pkgs.noto-fonts-color-emoji;
      family = "Noto Color Emoji";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.default.package
      cfg.monospace.package
      cfg.emoji.package
    ];

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ cfg.default.family ];
        emoji = [ cfg.emoji.family ];
      };
    };
  };
}
