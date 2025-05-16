{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.modules.docker;
in
{
  options.modules.docker = {
    enable = lib.mkEnableOption "";
    useCompose = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.docker
      (lib.mkIf cfg.useCompose pkgs.docker-compose)
    ];
  };
}
