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

  includeIfFor =
    { when, config }:
    let
      file = toml.generate "config.toml" config;
    in
    builtins.map (p: {
      name = "includeIf \"gitdir:${p}\"";
      value = {
        path = builtins.toString file;
      };
    }) when;
in
{
  options.programs.git = {
    scopes = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            when = lib.mkOption {
              type = lib.types.listOf lib.types.str;
            };
            config = lib.mkOption {
              type = lib.types.attrs;
            };
          };
        }
      );
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    programs.delta.enable = true;

    programs.git = {
      settings = lib.mkMerge [
        {
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
        }
        (lib.listToAttrs (lib.concatMap includeIfFor cfg.scopes))
      ];
      ignores = [
        ".zed"
        ".direnv/"
        ".env"
        ".envrc.local"
      ];
    };
  };
}
