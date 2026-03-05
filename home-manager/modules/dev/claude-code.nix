{
  config,
  pkgs,
  lib,
  user,
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

    home.file.".claude/rules" = {
      source = config.lib.file.mkOutOfStoreSymlink "${user.configDirectory}/claude/rules";
    };

    programs.git.ignores = lib.mkIf config.programs.git.enable [
      ".claude/settings.local.json"
    ];
  };
}
