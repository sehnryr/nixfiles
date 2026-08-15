{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.pi-coding-agent;
in
{
  options.programs.pi-coding-agent.enable = lib.mkEnableOption "pi-coding-agent";

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.unstable.pi-coding-agent
    ];

    home.file.".pi/agent/settings.json" = {
      source = config.lib.file.mkRelativeOutOfStoreSymlink ./settings.json;
    };
  };
}
