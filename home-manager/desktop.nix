{
  pkgs,
  user,
  ...
}:

{
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
    prism-launcher.enable = true;
    zen-browser.enable = true;
    zed-editor.enable = true;

    # desktop manager
    gnome-shell = {
      enable = true;
      extensionsPackages = [
        pkgs.gnomeExtensions.appindicator
      ];
      favoriteApps = [
        "zen-twilight.desktop"
        "dev.zed.Zed.desktop"
        "com.mitchellh.ghostty.desktop"
        "discord.desktop"
      ];
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
