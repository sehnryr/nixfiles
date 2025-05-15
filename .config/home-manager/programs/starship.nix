{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.starship;
in
{
  options.modules.starship = {
    enable = lib.mkEnableOption "";
    enableNushellIntegration = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableNushellIntegration = cfg.enableNushellIntegration;
      settings = {
        scala.detect_folders = [ ];
      };
    };
  };
}
