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
        "*".identityFile = [ ssh.private.path ];
        "melois.dev" = {
          hostname = "167.86.101.192";
          user = "root";
          port = 8422;
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
