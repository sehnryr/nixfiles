{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.carapace;

  enableNushellIntegration = config.modules.nushell.enable or false;
in
{
  options.modules.carapace = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    programs.carapace = {
      enable = true;
      enableNushellIntegration = enableNushellIntegration;
    };
  };
}
