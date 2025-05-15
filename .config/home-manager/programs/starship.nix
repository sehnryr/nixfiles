{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.starship;

  enableNushellIntegration = config.modules.nushell.enable or false;
in
{
  options.modules.starship = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableNushellIntegration = enableNushellIntegration;
      settings = {
        scala.detect_folders = [ ];
      };
    };
  };
}
