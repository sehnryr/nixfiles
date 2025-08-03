{
  config,
  pkgs,
  lib,
  ssh,
  ...
}:

let
  cfg = config.programs.ssh;
in
{
  config = lib.mkIf cfg.enable {
    programs.ssh = {
      addKeysToAgent = "yes";
      matchBlocks = {
        "*" = {
          identityFile = [ ssh.private.path ];
          setEnv.TERM = "xterm-256color";
        };
        "*.clever-cloud.com" = {
          identityFile = [ (toString config.age.secrets.clever-cloud-ssh.path) ];
        };
        "*.clvrcld.net" = {
          identityFile = [ (toString config.age.secrets.clever-cloud-ssh.path) ];
        };
      };
    };

    services.ssh-agent.enable = true;

    systemd.user.services."ssh-add-keys" = {
      Unit = {
        Description = "Load personal SSH keys into ssh-agent";
        After = [ "ssh-agent.service" ];
        Requires = [ "ssh-agent.service" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writers.writeBash "ssh-add-keys" ''
          ${pkgs.openssh}/bin/ssh-add ${
            lib.concatStringsSep " " [
              ssh.private.path
              (toString config.age.secrets.clever-cloud-ssh.path)
            ]
          }
        '';
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
