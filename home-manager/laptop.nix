{
  pkgs,
  lib,
  user,
  ssh,
  ...
}:

{
  home.username = user.name;
  home.homeDirectory = user.homeDirectory;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  age = {
    identityPaths = [ ssh.private.path ];
    secrets = {
      "arch-user-repository-ssh".file = ../secrets/arch-user-repository-ssh.age;
      "clever-cloud-ssh".file = ../secrets/clever-cloud-ssh.age;
      "upload-keystore.jks".file = ../secrets/upload-keystore.jks.age;
    };
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "slack"
    ];

  home.packages = with pkgs; [
    # cli
    tealdeer

    # gui
    nautilus # gnome file manager
    evince # gnome document viewer
    loupe # gnome image viewer
    gnome-disk-utility
    gnome-calculator
    libreoffice-fresh
    signal-desktop
    thunderbird
    resources
    slack
    vlc
  ];

  modules = {
    # cli
    nh.enable = true;
    ssh.enable = true;
    git.enable = true;
    direnv.enable = true;
    neovim.enable = true;
    nushell.enable = true;
    sccache.enable = true;
    carapace.enable = true;
    starship.enable = true;

    # gui
    discord.enable = true;
    ghostty.enable = true;
    zen-browser.enable = true;
    zed-editor.enable = true;

    # services
    syncthing = {
      enable = true;
      introducer.id = "2MFI55P-LSIS5AN-SKKZXOF-NJOELGG-U6UVN34-7O6HYIG-ZSDQJH5-QBURSAJ";
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
      showBatteryPercentage = false;
    };
  };

  programs.home-manager.enable = true;
}
