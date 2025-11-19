{
  config,
  pkgs,
  user,
  ...
}:

{
  home.file = {
    ".ssh/master.pub".enable = true;
    ".ssh/clever-cloud.pub".enable = true;
  };

  home.packages = with pkgs; [
    discord
    signal-desktop
    beeper
    slack
  ];

  programs = {
    # cli
    git = {
      enable = true;
      scopes = [
        {
          when = [
            "${user.homeDirectory}/clever-cloud"
          ];
          config = {
            user.email = "${user.name}.${user.family}@clever-cloud.com";
            user.signingKey = config.home.file.".ssh/clever-cloud.pub".text;
          };
        }
        {
          when = [
            "${user.homeDirectory}/stratorys"
          ];
          config = {
            user.email = "${user.name}.${user.family}@stratorys.com";
          };
        }
      ];
    };
    jujutsu = {
      enable = true;
      scopes = [
        {
          when = [
            "${user.homeDirectory}/clever-cloud"
          ];
          config = {
            user.email = "${user.name}.${user.family}@clever-cloud.com";
            signing.key = config.home.file.".ssh/clever-cloud.pub".text;
            revset-aliases = {
              "immutable_heads()" = "builtin_immutable_heads() ~ remote_bookmarks(remote=glob:\"clever-*\")";
            };
          };
        }
        {
          when = [
            "${user.homeDirectory}/stratorys"
          ];
          config = {
            user.email = "${user.name}.${user.family}@stratorys.com";
          };
        }
      ];
    };

    # gui
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
