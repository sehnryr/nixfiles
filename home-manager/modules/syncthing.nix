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
    xdg.desktopEntries.syncthing-ui = {
      name = "";
      noDisplay = true;
    };
  };
}
