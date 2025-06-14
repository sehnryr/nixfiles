{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.starship;

  nushellEnabled = config.modules.nushell.enable or false;
in
{
  options.modules.starship = {
    enable = lib.mkEnableOption "enable starship";
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableNushellIntegration = nushellEnabled;
      settings = {
        scala.detect_folders = [ ];
      };
    };
  };
}
