{
  config,
  pkgs,
  lib,
  user,
  ...
}:
let
  cfg = config.programs.git;

  toml = pkgs.formats.toml { };
in
{
  config = lib.mkIf cfg.enable {
    programs.delta.enable = true;

    programs.git = {
      settings = {
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
          path = builtins.toString (
            toml.generate "config.toml" {
              user = {
                email = "${user.name}.${user.family}@clever.cloud";
                signingKey = config.home.file.".ssh/clever-cloud.pub".text;
              };
            }
          );
        };
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
