{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.carapace;

  nushellEnabled = config.modules.nushell.enable or false;
in
{
  options.modules.carapace = {
    enable = lib.mkEnableOption "enable carapace";
  };

  config = lib.mkIf cfg.enable {
    programs.carapace = {
      enable = true;
      enableNushellIntegration = nushellEnabled;
    };
  };
}
