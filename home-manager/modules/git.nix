{
  config,
  lib,
  user,
  ssh,
  ...
}:

let
  cfg = config.programs.git;
in
{
  config = lib.mkIf cfg.enable {
    programs.git = {
      delta = {
        enable = true;
      };
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
      };
      userName = user.name;
      userEmail = user.email;
      signing = {
        signByDefault = true;
        format = "ssh";
        key = ssh.public.text;
      };
      ignores = [
        ".zed"
        ".direnv/"
        ".env"
        ".envrc.local"
      ];
    };
  };
}
