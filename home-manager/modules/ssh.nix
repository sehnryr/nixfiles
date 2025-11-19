{
  config,
  lib,
  ...
}:

let
  cfg = config.programs.ssh;
in
{
  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          identityAgent = "~/.1password/agent.sock";
          setEnv.TERM = "xterm-256color";
        };
      };
    };
  };
}
