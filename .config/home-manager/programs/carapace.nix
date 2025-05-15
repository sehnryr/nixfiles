{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.carapace;
in
{
  options.modules.carapace = {
    enable = lib.mkEnableOption "";
    enableNushellIntegration = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.carapace = {
      enable = true;
      enableNushellIntegration = cfg.enableNushellIntegration;
    };
  };
}
