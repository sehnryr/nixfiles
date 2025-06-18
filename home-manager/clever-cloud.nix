{
  pkgs,
  lib,
  ssh,
  ...
}:

{
  age = {
    identityPaths = [ ssh.private.path ];
    secrets = {
      "arch-user-repository-ssh".file = ../secrets/arch-user-repository-ssh.age;
      "clever-cloud-ssh".file = ../secrets/clever-cloud-ssh.age;
    };
  };

  home.file = {
    ".ssh/master.pub".enable = true;
    ".ssh/clever-cloud.pub".enable = true;
    ".ssh/arch-user-repository.pub".enable = true;
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "slack"
    ];

  home.packages = with pkgs; [
    slack
  ];

  modules = {
    # gui
    discord.enable = true;
    ghostty.enable = true;
    zen-browser.enable = true;
    zed-editor.enable = true;

    # desktop manager
    gnome-shell = {
      enable = true;
      extensions = [
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
