{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.lutris;
in
{
  options.programs.lutris = {
    enable = lib.mkEnableOption "lutris";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ lutris ];
  };
}
