{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.nushell;
in
{
  options.modules.nushell = {
    enable = lib.mkEnableOption "enable nushell";
  };

  config = lib.mkIf cfg.enable {
    home.shell.enableNushellIntegration = true;

    programs.nushell = {
      enable = true;
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
    };
  };
}
