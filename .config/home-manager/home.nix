{
  config,
  pkgs,
  lib,
  nixgl,
  ...
}:

let
  krisp-patcher =
    pkgs.writers.writePython3Bin "krisp-patcher"
      {
        libraries = [
          pkgs.python3Packages.capstone
          pkgs.python3Packages.pyelftools
        ];
        flakeIgnore = [
          "E501" # line too long (82 > 79 characters)
          "F403" # 'from module import *' used; unable to detect undefined names
          "F405" # name may be undefined, or defined from star imports: module
        ];
      }
      (
        builtins.readFile (
          pkgs.fetchurl {
            url = "https://pastebin.com/raw/8tQDsMVd";
            sha256 = "sha256-IdXv0MfRG1/1pAAwHLS2+1NESFEz2uXrbSdvU9OvdJ8=";
          }
        )
      );
in
{
  nixGL = {
    packages = nixgl.packages;
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
    vulkan.enable = true;
  };

  home.username = "youn";
  home.homeDirectory = "/home/youn";

  home.stateVersion = "24.11";

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "slack"
    ];

  home.packages = [
    pkgs.cmake
    pkgs.bun
    pkgs.deno
    pkgs.wget
    pkgs.fastfetch
    pkgs.rclone
    pkgs.tealdeer
    pkgs.fd
    pkgs.dust
    pkgs.hyperfine
    pkgs.cargo-binstall
    pkgs.uv
    pkgs.bruno
    pkgs.libreoffice-fresh
    pkgs.thunderbird
    pkgs.slack
    pkgs.signal-desktop
    pkgs.prismlauncher
    pkgs.protonvpn-gui
    (config.lib.nixGL.wrap pkgs.r2modman)

    krisp-patcher
    (config.lib.nixGL.wrap (pkgs.discord.override { withOpenASAR = true; }))
  ];

  home.activation = {
    patchKrisp = lib.hm.dag.entryAfter [ "installPackages" ] ''
      run /usr/bin/pkill -f discord || true

      for node in "${config.xdg.configHome}/discord/"*"/modules/discord_krisp/discord_krisp.node"; do
        run ${krisp-patcher}/bin/krisp-patcher "$node"
      done
    '';
  };

  xdg.configFile = {
    "wireplumber/wireplumber.conf.d/51-mitigate-annoying-profile-switch.conf" = {
      enable = true;
      text = ''
        wireplumber.settings = {
          bluetooth.autoswitch-to-headset-profile = false
        }

        monitor.bluez.properties = {
          bluez5.roles = [ a2dp_sink a2dp_source ]
        }
      '';
    };
  };

  xdg.dataFile = {
    "Steam/steam_dev.cfg" = {
      enable = true;
      text = ''
        @nClientDownloadEnableHTTP2PlatformLinux 0
      '';
    };
  };

  programs.home-manager.enable = true;

  modules = {
    git = {
      enable = true;
      user = {
        name = "Youn Mélois";
        email = "youn@melois.dev";
      };
      signing = {
        format = "ssh";
        key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      };
    };
    sccache.enable = true;
    rustup = {
      enable = true;
      enableSccacheIntegration = config.modules.sccache.enable;
      enableNushellIntegration = config.modules.nushell.enable;
    };
    nushell = {
      enable = true;
    };
    carapace = {
      enable = true;
      enableNushellIntegration = config.modules.nushell.enable;
    };
    starship = {
      enable = true;
      enableNushellIntegration = config.modules.nushell.enable;
    };
    direnv = {
      enable = true;
      enableNushellIntegration = config.modules.nushell.enable;
    };
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
    zed-editor = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.zed-editor;
      zedAlias = true;
      fonts.monospace.family = config.modules.fonts.monospace.family;
      enableNushellIntegration = config.modules.nushell.enable;
    };
    syncthing = {
      enable = true;
      introducer.id = "2MFI55P-LSIS5AN-SKKZXOF-NJOELGG-U6UVN34-7O6HYIG-ZSDQJH5-QBURSAJ";
      folders = {
        "Desktop" = {
          id = "desktop-sehn";
          path = "${config.home.homeDirectory}/Desktop";
        };
        "Pictures" = {
          id = "pictures-sehn";
          path = "${config.home.homeDirectory}/Pictures";
        };
        "Videos" = {
          id = "video-sehn";
          path = "${config.home.homeDirectory}/Videos";
        };
      };
    };
    ssh = {
      enable = true;
      matchBlocks = {
        "*" = {
          identityFile = [
            "${config.home.homeDirectory}/.ssh/id_ed25519"
          ];
        };
        "melois.dev" = {
          hostname = "melois.dev";
          user = "root";
          port = 8422;
        };
      };
      enableNushellIntegration = config.modules.nushell.enable;
    };
    fonts.enable = true;
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
      clock = {
        format = "24h";
        showSeconds = true;
        showWeekend = true;
      };
      fonts = {
        default = {
          family = config.modules.fonts.default.family;
          size = config.modules.fonts.default.size;
        };
        monospace = {
          family = config.modules.fonts.monospace.family;
          size = config.modules.fonts.monospace.size;
        };
      };
      # TODO: conditionally enable when on laptop
      showBatteryPercentage = true;
    };
    ghostty = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.ghostty;
      theme = {
        light = "Monokai Pro Light";
        dark = "Monokai Pro";
      };
      fonts.monospace = {
        family = config.modules.fonts.monospace.family;
        size = config.modules.fonts.monospace.size;
      };
      enableNushellIntegration = config.modules.nushell.enable;
    };
  };

  programs.topgrade = {
    enable = true;
    settings = {
      misc = {
        assume_yes = true;
        disable = [
          "bun"
          "bun_packages"
          "containers"
          "deno"
          "firmware"
          "git_repos"
          "github_cli_extensions"
          "gnome_shell_extensions"
          "jet_brains_toolbox"
          "lensfun"
          "uv"
        ];
        set_title = false;
        cleanup = true;
      };
      post_commands = {
        "AMD firmware workaround" =
          "sudo sh -c '[[ -d /root/linux-firmware ]] && sudo cp -rf /root/linux-firmware/amd{,gpu,-ucode} /lib/firmware/' && echo 'Done' || echo 'No workaround needed'";
      };
    };
  };
}
