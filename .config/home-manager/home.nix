{ config, pkgs, lib, ... }:

{
  nixGL = {
    packages = import <nixgl> { inherit pkgs; };
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
    vulkan.enable = true;
  };

  home.username = "youn";
  home.homeDirectory = "/home/youn";

  home.stateVersion = "24.11";

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "discord" ];

  home.packages = [
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

    pkgs.python313Packages.pip
    pkgs.uv

    pkgs.sccache

    pkgs.bruno

    (config.lib.nixGL.wrap (pkgs.discord.override { withOpenASAR = true; }))

    pkgs.maple-mono.NF

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

  home.shellAliases = { zed = "zeditor"; };
  home.shell.enableNushellIntegration = true;

  home.file = {
    ".cargo/config.toml" = {
      enable = true;
      text = ''
        [build]
        rustc-wrapper = "/usr/bin/sccache"
      '';
    };
  };

  xdg.configFile = {
    "wireplumber/wireplumber.conf.d/51-mitigate-annoying-profile-switch.conf" =
      {
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

  fonts.fontconfig = {
    enable = true;
    defaultFonts.monospace = [ "Maple Mono NF" ];
  };

  programs.home-manager.enable = true;

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
          "firmware"
          "toolbx"
          "containers"
          "gnome_shell_extensions"
          "github_cli_extensions"
          "bun_packages"
          "jetbrains_toolbox"
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
      key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
    extraConfig = { init.defaultBranch = "main"; };
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
    configFile.text = ''
      $env.SSH_AUTH_SOCK = $env.XDG_RUNTIME_DIR | path join "ssh-agent.socket"

      $env.PROMPT_COMMAND_RIGHT = ""

      use std/util 'path add'
      path add ($env.HOME | path join ".cargo/bin")

      use completions/cargo-completions.nu *
      use completions/curl-completions.nu *
      use completions/docker-completions.nu *
      use completions/git-completions.nu *
      use completions/less-completions.nu *
      use completions/make-completions.nu *
      use completions/man-completions.nu *
      use completions/nix-completions.nu *
      use completions/rustup-completions.nu *
      use completions/ssh-completions.nu *
      use completions/tar-completions.nu *
      use completions/tldr-completions.nu *
      use completions/uv-completions.nu *
    '';
  };

  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = { scala.detect_folders = [ ]; };
  };

  programs.direnv = {
    enable = true;
    enableNushellIntegration = true;
    nix-direnv.enable = true;
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
    ];
    extraPackages = [ pkgs.nil pkgs.nixd pkgs.ruff ];
    userSettings = {
      show_edit_predictions = true;
      tab_size = 4;
      preferred_line_length = 100;
      soft_wrap = "editor_width";
      wrap_guides = [ 80 100 ];
      ui_font_size = 14;
      buffer_font_size = 14;
      buffer_font_family = "Maple Mono NF";
      format_on_save = "on";
      theme = {
        mode = "system";
        light = "One Light";
        dark = "Ayu Dark";
      };
      terminal.font_family = "Maple Mono NF";
      languages = {
        "YAML".tab_size = 2;
        "Ruby".tab_size = 2;
        "Python" = {
          language_servers = [ "ruff" ];
          formatter = [{ language_server.name = "ruff"; }];
        };
        "Nix" = {
          tab_size = 2;
          formatter = [{ external.command = "nixfmt"; }];
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
}
