{
  config,
  lib,
  ...
}:

let
  cfg = config.programs.nushell;
in
{
  config = lib.mkIf cfg.enable {
    home.shell.enableNushellIntegration = true;

    programs.nushell = {
      settings = {
        show_banner = false;
        history = {
          file_format = "sqlite";
          max_size = 1000000;
          sync_on_enter = true;
          isolation = true;
        };
        ls.clickable_links = false;
        rm.always_trash = true;
      };
      environmentVariables = config.home.sessionVariables;
    };
  };
}
