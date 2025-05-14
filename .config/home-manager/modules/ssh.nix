{
  config,
  lib,
  ...
}:

let
  sshDirectory = "${config.home.homeDirectory}/.ssh";
  publicKeys = builtins.filter (name: builtins.match ".*\\.pub$" name != null) (
    builtins.attrNames (builtins.readDir sshDirectory)
  );
  privateKeys = builtins.map (lib.strings.removeSuffix ".pub") publicKeys;
in
{
  options.modules.ssh = {
    enable = lib.mkEnableOption "SSH configuration";
  };

  config = lib.mkIf config.modules.ssh.enable {
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
  };
}
