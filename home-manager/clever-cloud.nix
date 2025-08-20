{
  pkgs,
  ...
}:

{
  home.file = {
    ".ssh/master.pub".enable = true;
    ".ssh/clever-cloud.pub".enable = true;
    ".ssh/arch-user-repository.pub".enable = true;
  };

  home.packages = with pkgs; [
    slack
  ];

  programs = {
    # gui
    discord.enable = true;
    ghostty.enable = true;
    zen-browser.enable = true;
    zed-editor.enable = true;

    # desktop manager
    gnome-shell = {
      enable = true;
      extensionsPackages = [
        pkgs.gnomeExtensions.appindicator
      ];
      experimentalFeatures = [
        "scale-monitor-framebuffer"
        "xwayland-native-scaling"
      ];
      favoriteApps = [
        "zen-twilight.desktop"
        "dev.zed.Zed.desktop"
        "com.mitchellh.ghostty.desktop"
        "discord.desktop"
      ];
      showBatteryPercentage = true;
    };
  };
}
