{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.logind;
in
{
  options.modules.logind.enable = lib.mkEnableOption "logind";
  options.services.logind.enable = lib.mkOption {
    type = lib.types.bool;
    default = cfg.enable;
  };

  config = lib.mkIf cfg.enable {
    services.logind = {
      # enable = true;
      settings = {
        Login = {
          HandleLidSwitch = "suspend";
          HandleLidSwitchDocked = "suspend";
          HandleLidSwitchExternalPower = "suspend";

          HandlePowerKey = "suspend";
          HandlePowerKeyLongPress = "poweroff";
        };
      };
    };
  };
}
