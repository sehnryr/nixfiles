{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.gnome;
in
{
  options.modules.gnome.enable = lib.mkEnableOption "GNOME Desktop Environment";

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;

    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    services.xserver.excludePackages = with pkgs; [ xterm ];

    services.gnome.core-apps.enable = false;
    services.gnome.localsearch.enable = false;
    services.gnome.tinysparql.enable = false;

    environment.gnome.excludePackages = with pkgs; [ gnome-tour ];
  };
}
