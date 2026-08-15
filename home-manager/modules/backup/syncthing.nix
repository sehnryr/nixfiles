{
  config,
  lib,
  ...
}:
let
  cfg = config.services.syncthing;
in
{
  config = lib.mkIf cfg.enable {
    services.syncthing = {
      overrideDevices = false;
      overrideFolders = false;

      settings = {
        gui.enable = true;
        options = {
          announceLANAddresses = false;
          localAnnounceEnabled = false;
          globalAnnounceEnabled = false;
          relaysEnabled = false;
          natEnabled = false;
        };
      };
    };

    xdg.desktopEntries.syncthing-ui = {
      name = "";
      noDisplay = true;
    };
  };
}
