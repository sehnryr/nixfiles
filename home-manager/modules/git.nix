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
        "includeIf \"gitdir:${user.homeDirectory}/clever-cloud\"" = {
          path = builtins.toString config.xdg.configFile."git/work".source;
        };
        "includeIf \"gitdir:${user.homeDirectory}/Code/clever-cloud\"" = {
          path = builtins.toString config.xdg.configFile."git/work".source;
        };
      };
      userName = user.fullName;
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

    xdg.configFile."git/work" = {
      text = ''
        [user]
        email = "${user.name}.${user.family}@clever-cloud.com"
        signingKey = "${config.home.file.".ssh/clever-cloud.pub".text}"
      '';
    };
  };
}
