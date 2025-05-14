{
  config,
  lib,
  ...
}:

{
  options.modules.services = {
    enable = lib.mkEnableOption "System services configuration";
    enableSyncthing = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Syncthing service";
    };
  };

  config = lib.mkIf config.modules.services.enable {
    services.syncthing = lib.mkIf config.modules.services.enableSyncthing {
      enable = true;
      settings = {
        devices = {
          "node-0" = {
            id = "2MFI55P-LSIS5AN-SKKZXOF-NJOELGG-U6UVN34-7O6HYIG-ZSDQJH5-QBURSAJ";
            introducer = true;
          };
        };
        folders = {
          "Desktop" = {
            enable = true;
            id = "desktop-sehn";
            path = "${config.home.homeDirectory}/Desktop";
            devices = [ "node-0" ];
          };
          "Pictures" = {
            enable = true;
            id = "pictures-sehn";
            path = "${config.home.homeDirectory}/Pictures";
            devices = [ "node-0" ];
          };
          "Videos" = {
            enable = true;
            id = "video-sehn";
            path = "${config.home.homeDirectory}/Videos";
            devices = [ "node-0" ];
          };
        };
      };
    };
  };
}
