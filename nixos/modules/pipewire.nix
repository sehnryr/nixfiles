{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.pipewire;
in
{
  options.modules.pipewire.enable = lib.mkEnableOption "Pipewire";

  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;

    services.pulseaudio.enable = false;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      extraConfig.pipewire = {
        "10-airplay" = {
          "context.modules" = [
            { name = "libpipewire-module-raop-discover"; }
          ];
        };
      };
    };
  };
}
