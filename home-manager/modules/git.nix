{
  config,
  lib,
  user,
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
        user = {
          name = user.fullName;
          email = user.email;
          signingKey = config.home.file.".ssh/master.pub".text;
        };
        gpg = {
          format = "ssh";
        };
        "gpg \"ssh\"" = {
          program = "op-ssh-sign";
        };
        tag = {
          gpgSign = true;
        };
        init = {
          defaultBranch = "main";
        };
        pull = {
          rebase = true;
        };
        "includeIf \"gitdir:${user.homeDirectory}/clever-cloud\"" = {
          path = builtins.toString config.xdg.configFile."git/work".source;
        };
        "includeIf \"gitdir:${user.homeDirectory}/Code/clever-cloud\"" = {
          path = builtins.toString config.xdg.configFile."git/work".source;
        };
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
