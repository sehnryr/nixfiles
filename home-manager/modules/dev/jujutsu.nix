{
  config,
  pkgs,
  lib,
  user,
  ...
}:
let
  cfg = config.programs.jujutsu;
in
{
  config = lib.mkIf cfg.enable {
    programs.jujutsu = {
      package = pkgs.unstable.jujutsu;
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
          commit_trailers = "format_signed_off_by_trailer(self)";
        };
        git = {
          executable-path = "${config.programs.git.package}/bin/git";
          private-commits = "description(glob:'private:*')";
        };
        "--scope" = [
          {
            "--when".repositories = [ "${user.homeDirectory}/clever-cloud" ];
            user.email = "${user.name}.${user.family}@clever.cloud";
            signing.key = config.home.file.".ssh/clever-cloud.pub".text;
            revset-aliases = {
              "immutable_heads()" = "builtin_immutable_heads() ~ remote_bookmarks(remote=glob:\"clever-*\")";
            };
          }
        ];
      };
    };

    # jj doesn't seem to read `$XDG_CONFIG_HOME/git/ignore` although it should be:
    # https://jj-vcs.github.io/jj/latest/working-copy/#ignored-files
    home.file.".gitignore" = {
      text = builtins.concatStringsSep "\n" config.programs.git.ignores;
    };
  };
}
