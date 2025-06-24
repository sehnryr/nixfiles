{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.steam;
in
{
  options.modules.steam = {
    enable = lib.mkEnableOption "enable steam";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      extest.enable = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    hardware.steam-hardware.enable = true;
    programs.gamemode.enable = true;
  };
}
