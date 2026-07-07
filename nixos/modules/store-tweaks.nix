{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.store-tweaks;
in
{
  options.modules.store-tweaks.enable = lib.mkEnableOption "Nix store tweaks";

  config = lib.mkIf cfg.enable {
    boot.loader.systemd-boot.configurationLimit = lib.mkIf config.boot.loader.systemd-boot.enable 3;

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    nix.settings.auto-optimise-store = true;
  };
}
