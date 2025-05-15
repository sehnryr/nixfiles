{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.ssh;
in
{
  options.modules.ssh = {
    enable = lib.mkEnableOption "";
    matchBlocks = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            hostname = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };
            user = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };
            port = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              default = null;
            };
            identityFile = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.oneOf [
                  (lib.types.listOf lib.types.str)
                  lib.types.str
                ]
              );
              default = null;
            };
          };
        }
      );
      default = { };
    };
    enableNushellIntegration = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      addKeysToAgent = "yes";
      matchBlocks = cfg.matchBlocks;
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

    programs.nushell = lib.mkIf cfg.enableNushellIntegration {
      environmentVariables.SSH_AUTH_SOCK = lib.hm.nushell.mkNushellInline ''$env.XDG_RUNTIME_DIR | path join "ssh-agent.socket"'';
    };
  };
}
