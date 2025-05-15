{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.modules.gnome-shell = {
    enable = lib.mkEnableOption "Enable Gnome Shell";
    extensions = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };
    experimentalFeatures = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    favoriteApps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    accentColor = lib.mkOption {
      type = lib.types.str;
      default = "orange";
    };
    clock = {
      format = lib.mkOption {
        type = lib.types.enum [
          "12h"
          "24h"
        ];
        default = "24h";
      };
      showSeconds = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      showWeekend = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
    showBatteryPercentage = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    font = {
      default = {
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.cantarell-fonts;
        };
        name = lib.mkOption {
          type = lib.types.str;
          default = "Cantarell";
        };
        size = lib.mkOption {
          type = lib.types.int;
          default = 11;
        };
      };
      monospace = {
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.maple-mono.NF;
        };
        name = lib.mkOption {
          type = lib.types.str;
          default = "Maple Mono NF";
        };
        size = lib.mkOption {
          type = lib.types.int;
          default = 10;
        };
      };
      emoji = {
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.noto-fonts-color-emoji;
        };
        name = lib.mkOption {
          type = lib.types.str;
          default = "Noto Color Emoji";
        };
      };
    };
  };

  config =
    with config.modules.gnome-shell;
    lib.mkIf config.modules.gnome-shell.enable {
      home.packages = [
        font.default.package
        font.monospace.package
        font.emoji.package
      ];

      fonts.fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ font.default.name ];
          emoji = [ font.emoji.name ];
        };
      };

      programs.gnome-shell = {
        enable = true;
        extensions = builtins.map (extension: {
          package = extension;
        }) extensions;
      };

      dconf.settings = {
        "org/gnome/shell" = {
          favorite-apps = favoriteApps;
        };
        "org/gnome/desktop/interface" = {
          accent-color = accentColor;
          clock-format = clock.format;
          clock-show-seconds = clock.showSeconds;
          clock-show-weekend = clock.showWeekend;
          show-battery-percentage = showBatteryPercentage;
          font-name = "${font.default.name} ${builtins.toString font.default.size}";
          document-font-name = "${font.default.name} ${builtins.toString font.default.size}";
          monospace-font-name = "${font.monospace.name} ${builtins.toString font.monospace.size}";
        };
        "org/gnome/desktop/wm/keybindings" = {
          # disable those keybindings since ghostty uses them
          # TODO: conditionally disable keybindings when ghostty is enabled
          switch-to-workspace-up = [ ];
          switch-to-workspace-down = [ ];
          switch-to-workspace-left = [ ];
          switch-to-workspace-right = [ ];
        };
        "org/gnome/mutter" = {
          experimental-features = experimentalFeatures;
        };
      };
    };
}
