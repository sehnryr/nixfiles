{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.fonts;
in
{
  options.modules.fonts.enable = lib.mkEnableOption "Fonts";

  config = lib.mkIf cfg.enable {
    fonts = {
      packages = [
        pkgs.cantarell-fonts
        pkgs.dejavu_fonts
        pkgs.maple-mono.NL-NF
        pkgs.noto-fonts-cjk-sans
        pkgs.noto-fonts-cjk-serif
        pkgs.noto-fonts-color-emoji
      ];
      fontconfig = {
        enable = true;
        defaultFonts = {
          sansSerif = [
            "Cantarell"
            "Noto Sans CJK"
          ];
          serif = [
            "DejaVu Serif"
            "Noto Serif CJK"
          ];
          monospace = [ "Maple Mono NL NF" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}
