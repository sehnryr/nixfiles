{
  config,
  lib,
  ssh,
  ...
}:

let
  cfg = config.modules.ssh;
in
{
  options.modules.ssh = {
    enable = lib.mkEnableOption "enable ssh";
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      addKeysToAgent = "yes";
      matchBlocks = {
        "*" = {
          identityFile = [ ssh.private.path ];
          setEnv = {
            TERM = "xterm-256color";
          };
        };
        "*.clever-cloud.com".identityFile = [
          (toString config.age.secrets.clever-cloud-ssh.path)
        ];
        "*.clvrcld.net".identityFile = [
          (toString config.age.secrets.clever-cloud-ssh.path)
        ];
      };
    };

    services.ssh-agent.enable = true;
  };
}
