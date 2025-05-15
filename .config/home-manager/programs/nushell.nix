{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.modules.nushell;
  ssh = config.modules.ssh;
  rustup = config.modules.rustup;
in
{
  options.modules.nushell = {
    enable = lib.mkEnableOption "";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nushell;
    };
    useCarapace = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    useStarship = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    useDirenv = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    home.shell.enableNushellIntegration = true;

    programs.nushell = lib.mkMerge [
      {
        enable = true;
        package = cfg.package;
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
        environmentVariables.BINSTALL_NO_CONFIRM = "";
      }
      (lib.mkIf ssh.enable {
        environmentVariables.SSH_AUTH_SOCK = lib.hm.nushell.mkNushellInline ''$env.XDG_RUNTIME_DIR | path join "ssh-agent.socket"'';
      })
      (lib.mkIf rustup.enable {
        configFile.text = ''
          use std/util "path add"
          path add "${config.home.homeDirectory}/.cargo/bin"
        '';
      })
    ];

    programs.carapace = lib.mkIf cfg.useCarapace {
      enable = true;
      enableNushellIntegration = true;
    };

    programs.starship = lib.mkIf cfg.useStarship {
      enable = true;
      enableNushellIntegration = true;
      settings = {
        scala.detect_folders = [ ];
      };
    };

    programs.direnv = lib.mkIf cfg.useDirenv {
      enable = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
