{
  config,
  lib,
  user,
  ssh,
  ...
}:

let
  cfg = config.programs.jujutsu;
in
{
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
          key = ssh.public.text;
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
        "--scope" = [
          {
            "--when".repositories = [
              "${user.homeDirectory}/clever-cloud"
              "${user.homeDirectory}/Code/clever-cloud"
            ];
            user.email = "${user.name}.${user.family}@clever-cloud.com";
            signing.key = config.home.file.".ssh/clever-cloud.pub".text;
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
