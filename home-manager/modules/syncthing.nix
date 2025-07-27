{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.syncthing;
in
{
  options.modules.syncthing = {
    enable = lib.mkEnableOption "";
    overrideDevices = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      overrideDevices = cfg.overrideDevices;
      settings = cfg.settings;
    };

    xdg.desktopEntries.syncthing-ui = {
      name = "";
      noDisplay = true;
    };
  };
}
