{
  config,
  lib,
  ...
}:

let
  cfg = config.programs.steam;
in
{
  config = lib.mkIf cfg.enable {
    programs.steam = {
      extest.enable = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    hardware.steam-hardware.enable = true;
    programs.gamemode.enable = true;
  };
}
