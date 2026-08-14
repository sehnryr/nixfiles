{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.tailscale;
in
{
  options.modules.tailscale = {
    enable = lib.mkEnableOption "Tailscale client";

    loginServer = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.tailscale-authkey.file = ../../secrets/tailscale-authkey.age;

    services.tailscale = {
      enable = true;
      openFirewall = true;

      disableUpstreamLogging = true;

      authKeyFile = config.age.secrets.tailscale-authkey.path;

      extraUpFlags = [ "--login-server=${cfg.loginServer}" ];
    };

    systemd.services.tailscaled-autoconnect = {
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "10s";
      };
    };

    networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];
  };
}
