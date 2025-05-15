{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.gnome-shell;
  fonts = config.modules.fonts;
in
{
  options.modules.gnome-shell = {
    enable = lib.mkEnableOption "";
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
  };

  config = lib.mkIf cfg.enable {
    programs.gnome-shell = {
      enable = true;
      extensions = builtins.map (extension: {
        package = extension;
      }) cfg.extensions;
    };

    dconf.settings = {
      "org/gnome/shell" = {
        favorite-apps = cfg.favoriteApps;
      };
      "org/gnome/desktop/interface" = lib.mkMerge [
        {
          accent-color = cfg.accentColor;
          clock-format = cfg.clock.format;
          clock-show-seconds = cfg.clock.showSeconds;
          clock-show-weekend = cfg.clock.showWeekend;
          show-battery-percentage = cfg.showBatteryPercentage;
        }
        (lib.mkIf fonts.enable {
          font-name = "${fonts.default.family} ${builtins.toString fonts.default.size}";
          document-font-name = "${fonts.default.family} ${builtins.toString fonts.default.size}";
          monospace-font-name = "${fonts.monospace.family} ${builtins.toString fonts.monospace.size}";
        })
      ];
      "org/gnome/desktop/wm/keybindings" = {
        # disable those keybindings since ghostty uses them
        # TODO: conditionally disable keybindings when ghostty is enabled
        switch-to-workspace-up = [ ];
        switch-to-workspace-down = [ ];
        switch-to-workspace-left = [ ];
        switch-to-workspace-right = [ ];
      };
      "org/gnome/mutter" = {
        experimental-features = cfg.experimentalFeatures;
      };
    };
  };
}
