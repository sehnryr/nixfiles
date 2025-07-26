{
  pkgs,
  user,
  ssh,
  ...
}:

{
  age = {
    identityPaths = [ ssh.private.path ];
    secrets = {
      "arch-user-repository-ssh".file = ../secrets/arch-user-repository-ssh.age;
      "clever-cloud-ssh".file = ../secrets/clever-cloud-ssh.age;
      "upload-keystore.jks".file = ../secrets/upload-keystore.jks.age;
      "sccache-aws-credentials".file = ../secrets/sccache-aws-credentials.age;
    };
  };

  home.file = {
    ".ssh/master.pub".enable = true;
    ".ssh/clever-cloud.pub".enable = true;
    ".ssh/arch-user-repository.pub".enable = true;
  };

  home.packages = with pkgs; [
    signal-desktop
    slack
  ];

  modules = {
    # gui
    discord.enable = true;
    ghostty.enable = true;
    zen-browser.enable = true;
    zed-editor.enable = true;

    # services
    syncthing = {
      enable = true;
      introducer.id = "GNRP5VZ-TGG7IN3-YSQHR6A-VMHHGYH-TMGVFVR-ZP7Y7XU-WE53UAZ-3GLQCA2";
      folders = {
        "Desktop" = {
          id = "desktop-sehn";
          path = "${user.homeDirectory}/Desktop";
        };
        "Pictures" = {
          id = "pictures-sehn";
          path = "${user.homeDirectory}/Pictures";
        };
        "Videos" = {
          id = "video-sehn";
          path = "${user.homeDirectory}/Videos";
        };
      };
    };

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
