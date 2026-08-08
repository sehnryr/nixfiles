{
  config,
  lib,
  user,
  ...
}:

let
  cfg = config.programs.ssh;
in
{
  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enableDefaultConfig = false;
      settings = {
        "Host *" = {
          IdentityAgent = "${user.homeDirectory}/.1password/agent.sock";
          SetEnv.TERM = "xterm-256color";
        };
      };
    };
  };
}
