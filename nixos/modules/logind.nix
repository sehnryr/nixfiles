{ ... }:

{
  config = {
    services.logind = {
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
