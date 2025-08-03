{
  config,
  lib,
  ...
}:

let
  cfg = config.services.fprintd;
in
{
  config = lib.mkIf cfg.enable {
    systemd.services.fprintd = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "simple";
    };
  };
}
