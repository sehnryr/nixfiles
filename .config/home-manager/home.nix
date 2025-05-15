{
  config,
  pkgs,
  lib,
  nixgl,
  ...
}:

let
  fonts = config.modules.fonts;

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
    pkgs.less
    pkgs.cmake
    pkgs.bun
    pkgs.deno
    pkgs.rustup
    pkgs.wget
    pkgs.fastfetch
    pkgs.rclone
    pkgs.tealdeer
    pkgs.fd
    pkgs.dust
    pkgs.hyperfine
    pkgs.cargo-binstall
    pkgs.uv
    pkgs.sccache
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

  home.file = {
    ".cargo/config.toml" = {
      enable = true;
      text = ''
        [build]
        rustc-wrapper = "${pkgs.sccache}/bin/sccache"
      '';
    };
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
      userName = "Youn Mélois";
      userEmail = "youn@melois.dev";
    };
    shell = {
      enable = true;
      useNushell = true;
    };
    editors = {
      enable = true;
      enableNeovim = true;
      enableZed = true;
    };
    services = {
      enable = true;
      enableSyncthing = true;
    };
    ssh.enable = true;
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
      # TODO: conditionally enable when on laptop
      showBatteryPercentage = true;
    };
    ghostty = {
      enable = true;
      theme = {
        light = "Monokai Pro Light";
        dark = "Monokai Pro";
      };
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
