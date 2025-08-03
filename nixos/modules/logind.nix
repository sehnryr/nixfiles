{ ... }:

{
  config = {
    services.logind = {
      lidSwitch = "suspend";
      lidSwitchDocked = "suspend";
      lidSwitchExternalPower = "suspend";

      powerKey = "suspend";
      powerKeyLongPress = "poweroff";
    };
  };
}
