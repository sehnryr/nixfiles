{
  config,
  pkgs,
  lib,
  nixgl,
  ...
}:

let
  sshDirectory = "${config.home.homeDirectory}/.ssh";
  publicKeys = builtins.filter (name: builtins.match ".*\\.pub$" name != null) (
    builtins.attrNames (builtins.readDir sshDirectory)
  );
  privateKeys = builtins.map (lib.strings.removeSuffix ".pub") publicKeys;

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
rec {
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

    pkgs.maple-mono.NF
    pkgs.noto-fonts-color-emoji

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  home.activation = {
    patchKrisp = lib.hm.dag.entryAfter [ "installPackages" ] ''
      run /usr/bin/pkill -f discord || true

      for node in "${config.xdg.configHome}/discord/"*"/modules/discord_krisp/discord_krisp.node"; do
        run ${krisp-patcher}/bin/krisp-patcher "$node"
      done
    '';
  };

  home.sessionPath = [ "${home.homeDirectory}/.cargo/bin" ];
  home.shellAliases = {
    zed = "zeditor";
  };
  home.shell.enableNushellIntegration = true;

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

  fonts.fontconfig = {
    enable = true;
    defaultFonts.monospace = [ "Maple Mono NF" ];
    defaultFonts.emoji = [ "Noto Color Emoji" ];
  };

  programs.home-manager.enable = true;

  programs.gnome-shell = {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.appindicator; }
    ];
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "*" = {
        identityFile = builtins.map (name: "${sshDirectory}/${name}") privateKeys;
      };
      "melois.dev" = {
        hostname = "melois.dev";
        user = "root";
        port = 8422;
      };
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
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

  programs.git = {
    enable = true;
    userName = "Youn Mélois";
    userEmail = "youn@melois.dev";
    signing = {
      format = "ssh";
      key = "${home.homeDirectory}/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  programs.nushell = {
    enable = true;
    settings = {
      show_banner = false;
      history = {
        file_format = "sqlite";
        max_size = 1000000;
        sync_on_enter = true;
        isolation = true;
      };
      ls.clickable_links = false;
      rm.always_trash = true;
    };
    environmentVariables = {
      SSH_AUTH_SOCK = lib.hm.nushell.mkNushellInline ''$env.XDG_RUNTIME_DIR | path join "ssh-agent.socket"'';
    };
  };

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = {
      scala.detect_folders = [ ];
    };
  };

  programs.direnv = {
    enable = true;
    enableNushellIntegration = true;
    nix-direnv.enable = true;
  };

  programs.ghostty = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.ghostty;
    settings = {
      font-family = "Maple Mono NF";
      font-size = 10;
      theme = "light:Monokai Pro Light,dark:Monokai Pro";
      command = "${pkgs.nushell}/bin/nu";
      resize-overlay = "never";
    };
  };

  programs.zed-editor = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.zed-editor;
    installRemoteServer = true;
    extensions = [
      "html"
      "toml"
      "dockerfile"
      "git-firefly"
      "sql"
      "ruby"
      "make"
      "xml"
      "nix"
      "ruff"
      "deno"
      "proto"
      "scala"
      "nu"
      "wit"
      "scss"
      "angular"
    ];
    extraPackages = [
      pkgs.nil
      pkgs.nixd
      pkgs.nixfmt-rfc-style
      pkgs.ruff
    ];
    userSettings = {
      show_edit_predictions = true;
      tab_size = 4;
      preferred_line_length = 100;
      soft_wrap = "editor_width";
      wrap_guides = [
        80
        100
      ];
      ui_font_size = 14;
      buffer_font_size = 14;
      buffer_font_family = "Maple Mono NF";
      format_on_save = "on";
      theme = {
        mode = "system";
        light = "One Light";
        dark = "Ayu Dark";
      };
      terminal = {
        font_family = "Maple Mono NF";
        shell.program = "${pkgs.nushell}/bin/nu";
      };
      languages = {
        "YAML".tab_size = 2;
        "Ruby".tab_size = 2;
        "Python" = {
          language_servers = [ "ruff" ];
          formatter = [ { language_server.name = "ruff"; } ];
        };
        "Nix" = {
          tab_size = 2;
          formatter = [ { external.command = "nixfmt"; } ];
        };
      };
    };
  };

  services.syncthing = {
    enable = true;
    settings = {
      devices = {
        "node-0" = {
          id = "2MFI55P-LSIS5AN-SKKZXOF-NJOELGG-U6UVN34-7O6HYIG-ZSDQJH5-QBURSAJ";
          introducer = true;
        };
      };
      folders = {
        "Desktop" = {
          enable = true;
          id = "desktop-sehn";
          path = "${home.homeDirectory}/Desktop";
          devices = [ "node-0" ];
        };
        "Pictures" = {
          enable = true;
          id = "pictures-sehn";
          path = "${home.homeDirectory}/Pictures";
          devices = [ "node-0" ];
        };
        "Videos" = {
          enable = true;
          id = "video-sehn";
          path = "${home.homeDirectory}/Videos";
          devices = [ "node-0" ];
        };
      };
    };
  };

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

  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "zen.desktop"
        "dev.zed.Zed.desktop"
        "com.mitchellh.ghostty.desktop"
        "discord.desktop"
      ];
    };
    "org/gnome/desktop/interface" = {
      accent-color = "orange";
      clock-format = "24h";
      clock-show-seconds = true;
      clock-show-weekend = true;
      show-battery-percentage = true;
      font-name = "Cantarell 11";
      document-font-name = "Cantarell 11";
      monospace-font-name = "Maple Mono NF 10";
    };
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
  };
}
