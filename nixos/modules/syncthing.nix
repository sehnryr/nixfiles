{
  config,
  lib,
  user,
  ...
}:

let
  cfg = config.services.syncthing;
in
{
  config = lib.mkIf cfg.enable {
    services.syncthing = {
      overrideDevices = false;
      settings = {
        gui.enabled = false;
        devices = {
          "server" = {
            id = "TTUFKM7-A5RG55J-R3SN7YO-I2KAPCQ-FZROOD5-736WAXG-ZQXSIYZ-5PXUBAJ";
            introducer = true;
          };
        };
        folders = {
          "${user.homeDirectory}/Desktop".devices = [ "server" ];
          "${user.homeDirectory}/Pictures".devices = [ "server" ];
          "${user.homeDirectory}/Videos".devices = [ "server" ];
        };
      };
    };
  };
}
