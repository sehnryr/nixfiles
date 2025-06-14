{
  config,
  lib,
  user,
  ssh,
  ...
}:

let
  cfg = config.modules.git;
in
{
  options.modules.git = {
    enable = lib.mkEnableOption "enable git";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
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
    };
  };
}
