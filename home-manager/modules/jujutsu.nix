{
  config,
  lib,
  user,
  ...
}:

let
  cfg = config.programs.jujutsu;

  toWhenList =
    items:
    builtins.map (
      { when, config }:
      config
      // {
        "--when".repositories = when;
      }
    ) items;
in
{
  options.programs.jujutsu = {
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
    programs.jujutsu = {
      settings = {
        user = {
          name = user.fullName;
          email = user.email;
        };
        signing = {
          behavior = "own";
          backend = "ssh";
          key = config.home.file.".ssh/master.pub".text;
          backends = {
            ssh = {
              program = "op-ssh-sign";
            };
          };
        };
        ui = {
          default-command = [ "log" ];
          pager = "less -FR";
          conflict-marker-style = "git";
        };
        templates = {
          git_push_bookmark = ''"${user.name}/push-" ++ change_id.short()'';
        };
        git = {
          executable-path = "${config.programs.git.package}/bin/git";
          push-new-bookmarks = true;
          private-commits = "description(glob:'private:*')";
        };
        "--scope" = toWhenList cfg.scopes;
      };
    };

    # jj doesn't seem to read `$XDG_CONFIG_HOME/git/ignore` although it should be:
    # https://jj-vcs.github.io/jj/latest/working-copy/#ignored-files
    home.file.".gitignore" = {
      text = builtins.concatStringsSep "\n" config.programs.git.ignores;
    };
  };
}
