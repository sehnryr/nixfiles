{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.fprintd;
in
{
  options.modules.fprintd = {
    enable = lib.mkEnableOption "enable fprintd";
  };

  config = lib.mkIf cfg.enable {
    services.fprintd.enable = true;

    systemd.services.fprintd = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "simple";
    };
  };
}
