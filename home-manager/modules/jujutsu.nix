{
  config,
  lib,
  user,
  ssh,
  ...
}:

let
  cfg = config.modules.jujutsu;
in
{
  options.modules.jujutsu = {
    enable = lib.mkEnableOption "enable jujutsu";
  };

  config = lib.mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;
      settings = {
        inherit user;
        signing = {
          behavior = "own";
          backend = "ssh";
          key = ssh.public.text;
        };
        ui = {
          default-command = [ "log" ];
          pager = "less -FR";
        };
        git = {
          private-commits = "description(glob:'wip:*') | description(glob:'private:*')";
        };
      };
    };

    home.file.".gitignore" = {
      text = ''
        .zed/
        .direnv/
        .env
        .envrc.local
      '';
    };
  };
}
