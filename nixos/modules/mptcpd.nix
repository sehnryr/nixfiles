{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.mptcpd;
in
{
  options.modules.mptcpd.enable = lib.mkEnableOption "MPTCPD";

  config = lib.mkIf cfg.enable {
    services.mptcpd.enable = true;

    boot.kernel.sysctl = {
      "net.mptcp.enabled" = "1";
    };
  };
}
