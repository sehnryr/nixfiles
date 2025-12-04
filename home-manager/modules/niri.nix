{
  config,
  pkgs,
  lib,
  user,
  ...
}:

let
  cfg = config.programs.niri;
in
{
  options.programs.niri = {
    enable = lib.mkEnableOption "enable niri";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.niri;
      description = "The Niri window manager package";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.noctalia-shell
      pkgs.xwayland-satellite
    ];

    xdg.configFile."niri/config.kdl" = {
      source = config.lib.file.mkOutOfStoreSymlink "${user.configDirectory}/niri/config.kdl";
    };

    xdg.configFile."noctalia/settings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink "${user.configDirectory}/noctalia/settings.json";
    };
  };
}
