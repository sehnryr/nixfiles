{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.modules.theme = {
    enable = lib.mkEnableOption "Theme configuration";
    accentColor = lib.mkOption {
      type = lib.types.str;
      default = "orange";
      description = "GNOME accent color";
    };
    fontName = lib.mkOption {
      type = lib.types.str;
      default = "Cantarell 11";
      description = "Default font name";
    };
    documentFontName = lib.mkOption {
      type = lib.types.str;
      default = "Cantarell 11";
      description = "Document font name";
    };
    monospaceFontName = lib.mkOption {
      type = lib.types.str;
      default = "Maple Mono NF 10";
      description = "Monospace font name";
    };
  };

  config = lib.mkIf config.modules.theme.enable {
    fonts.fontconfig = {
      enable = true;
      defaultFonts.monospace = [ "Maple Mono NF" ];
      defaultFonts.emoji = [ "Noto Color Emoji" ];
    };

    dconf.settings = {
      "org/gnome/shell" = {
        favorite-apps = [
          "zen.desktop"
          "dev.zed.Zed.desktop"
          "com.mitchellh.ghostty.desktop"
          "discord.desktop"
        ];
      };
      "org/gnome/desktop/interface" = {
        accent-color = config.modules.theme.accentColor;
        clock-format = "24h";
        clock-show-seconds = true;
        clock-show-weekend = true;
        show-battery-percentage = true;
        font-name = config.modules.theme.fontName;
        document-font-name = config.modules.theme.documentFontName;
        monospace-font-name = config.modules.theme.monospaceFontName;
      };
      "org/gnome/desktop/wm/keybindings" = {
        switch-to-workspace-up = [ ];
        switch-to-workspace-down = [ ];
        switch-to-workspace-left = [ ];
        switch-to-workspace-right = [ ];
      };
      "org/gnome/mutter" = {
        experimental-features = [
          "scale-monitor-framebuffer"
          "xwayland-native-scaling"
        ];
      };
    };

    home.packages = [
      pkgs.maple-mono.NF
      pkgs.noto-fonts-color-emoji
    ];
  };
}
