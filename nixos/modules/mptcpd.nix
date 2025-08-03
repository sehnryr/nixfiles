{
  config,
  lib,
  ...
}:

let
  cfg = config.services.mptcpd;
in
{
  config = lib.mkIf cfg.enable {
    boot.kernel.sysctl = {
      "net.mptcp.enabled" = "1";
    };
  };
}
