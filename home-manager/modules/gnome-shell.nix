{
  config,
  lib,
  fonts,
  ...
}:

let
  cfg = config.modules.gnome-shell;

  ghosttyEnabled = config.modules.ghostty.enable or false;
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
      "org/gnome/desktop/interface" = {
        accent-color = "orange";
        clock-format = "24h";
        clock-show-seconds = true;
        clock-show-weekend = true;
        show-battery-percentage = cfg.showBatteryPercentage;
        font-name = "${fonts.sans.default.family} 11";
        document-font-name = "${fonts.sans.default.family} 11";
        monospace-font-name = "${fonts.monospace.default.family} 10";
      };
      "org/gnome/desktop/wm/keybindings" = lib.mkIf ghosttyEnabled {
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
