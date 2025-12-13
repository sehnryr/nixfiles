{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.desktop;

  moduleNames = builtins.attrNames (builtins.readDir ./.);
  modules = builtins.map (name: ./. + ("/" + name)) moduleNames;
  filterOut = module: modules: builtins.filter (module': module' != module) modules;
in
{
  imports = filterOut ./default.nix modules;

  options.modules.desktop = {
    enable = lib.mkEnableOption "desktop";
    device = lib.mkOption {
      type = lib.types.enum [
        "desktop"
        "laptop"
      ];
      description = "Device type";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # messaging
      discord
      signal-desktop
      slack

      # utilities
      nautilus # gnome file manager
      evince # gnome document viewer
      loupe # gnome image viewer
      gnome-disk-utility
      gnome-calculator
      libreoffice-fresh
      resources
      vlc
    ];

    programs = {
      ghostty.enable = true;
      zen-browser.enable = true;

      # desktop manager
      gnome-shell = {
        enable = true;
        extensionsPackages = [
          pkgs.gnomeExtensions.appindicator
        ];
        experimentalFeatures = lib.optionals (cfg.device == "laptop") [
          "scale-monitor-framebuffer"
          "xwayland-native-scaling"
        ];
        favoriteApps = [
          "zen-twilight.desktop"
          "dev.zed.Zed.desktop"
          "com.mitchellh.ghostty.desktop"
          "discord.desktop"
        ];
        showBatteryPercentage = (cfg.device == "laptop");
      };
    };
  };
}
