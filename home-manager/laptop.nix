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
    beeper
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

  services = {
    syncthing = {
      enable = true;
      overrideDevices = false;
      settings = {
        gui.enabled = false;
        devices = {
          "server" = {
            id = "TTUFKM7-A5RG55J-R3SN7YO-I2KAPCQ-FZROOD5-736WAXG-ZQXSIYZ-5PXUBAJ";
            introducer = true;
          };
        };
        folders = {
          "${user.homeDirectory}/Desktop".devices = [ "server" ];
          "${user.homeDirectory}/Pictures".devices = [ "server" ];
          "${user.homeDirectory}/Videos".devices = [ "server" ];
        };
      };
    };
  };
}
