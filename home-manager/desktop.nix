{
  config,
  pkgs,
  lib,
  nixgl,
  user,
  ssh,
  fonts,
  ...
}:

let
  getFonts = fonts: value: lib.mapAttrsToList (_: font: font.${value}) fonts;

  fontsSans = getFonts fonts.sans;
  fontsSerif = getFonts fonts.serif;
  fontsMonospace = getFonts fonts.monospace;
  fontsEmoji = getFonts fonts.emoji;
in
{
  # TODO: remove this when passing to nixos
  nixGL = {
    packages = nixgl.packages;
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
    vulkan.enable = true;
  };

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

  home.packages =
    with pkgs;
    [
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
    ]
    # TODO: remove this when passing to nixos
    ++ (fontsSans "package")
    ++ (fontsSerif "package")
    ++ (fontsMonospace "package")
    ++ (fontsEmoji "package");

  modules = {
    # cli
    ssh.enable = true;
    git.enable = true;
    direnv.enable = true;
    neovim.enable = true;
    nushell.enable = true;
    sccache.enable = true;
    carapace.enable = true;
    starship.enable = true;

    # gui
    discord = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.discord;
    };
    ghostty = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.ghostty;
    };
    zed-editor = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.zed-editor;
    };

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
        "zen.desktop"
        "dev.zed.Zed.desktop"
        "com.mitchellh.ghostty.desktop"
        "discord.desktop"
      ];
      showBatteryPercentage = false;
    };
  };

  # TODO: remove this when passing to nixos
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = fontsSans "family";
      serif = fontsSerif "family";
      monospace = fontsMonospace "family";
      emoji = fontsEmoji "family";
    };
  };

  # TODO: remove this when passing to nixos
  systemd.user = {
    services = {
      "ssh-agent" = {
        Unit.Description = "SSH key agent";
        Service = {
          Type = "simple";
          Environment = "SSH_AUTH_SOCK=%t/ssh-agent.socket";
          ExecStart = "/usr/bin/ssh-agent -D -a $SSH_AUTH_SOCK";
        };
        Install.WantedBy = [ "default.target" ];
      };
    };
  };

  # TODO: remove this when passing to nixos
  programs.nushell = lib.mkIf config.modules.nushell.enable {
    environmentVariables.SSH_AUTH_SOCK = lib.hm.nushell.mkNushellInline ''$env.XDG_RUNTIME_DIR | path join "ssh-agent.socket"'';
  };

  programs.home-manager.enable = true;
}
