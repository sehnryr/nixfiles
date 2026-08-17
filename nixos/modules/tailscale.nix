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

    useAuthKey = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    trustTailnet = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Trust all inbound traffic from the Tailscale interface";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = lib.mkIf cfg.useAuthKey {
      tailscale-authkey.file = ../../secrets/tailscale-authkey.age;
    };

    services.tailscale = {
      enable = true;
      openFirewall = true;

      disableUpstreamLogging = true;

      authKeyFile = lib.mkIf cfg.useAuthKey config.age.secrets.tailscale-authkey.path;

      extraUpFlags = [ "--login-server=${cfg.loginServer}" ];
    };

    systemd.services.tailscaled-autoconnect = {
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "10s";
      };
    };

    networking.firewall.trustedInterfaces = lib.mkIf cfg.trustTailnet [
      config.services.tailscale.interfaceName
    ];
  };
}
