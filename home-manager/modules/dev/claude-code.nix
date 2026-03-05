{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.claude-code;
in
{
  config = lib.mkIf cfg.enable {
    programs.claude-code = {
      package = pkgs.claude-code;
    };

    programs.git.ignores = lib.mkIf config.programs.git.enable [
      ".claude/settings.local.json"
    ];
  };
}
