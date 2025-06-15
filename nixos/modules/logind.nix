{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.logind;
in
{
  options.modules.logind = {
    enable = lib.mkEnableOption "enable logind";
  };

  config = lib.mkIf cfg.enable {
    services.logind = {
      lidSwitch = "suspend";
      lidSwitchDocked = "suspend";
      lidSwitchExternalPower = "suspend";

      powerKey = "suspend";
      powerKeyLongPress = "poweroff";
    };
  };
}
