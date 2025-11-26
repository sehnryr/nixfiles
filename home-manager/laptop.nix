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
    slack
  ];

  programs = {
    onepassword-secrets.enable = true;

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
    codex.enable = true;

    # gui
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
    syncthing.enable = true;
  };

  xdg.configFile."tombi/config.toml" = {
    source = config.lib.file.mkOutOfStoreSymlink "${user.configDirectory}/tombi/config.toml";
  };
}
