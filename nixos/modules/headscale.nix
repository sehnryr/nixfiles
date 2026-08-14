{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.headscale;
in
{
  options.modules.headscale = {
    enable = lib.mkEnableOption "Headscale coordination server";

    hostname = lib.mkOption {
      type = lib.types.str;
    };

    baseDomain = lib.mkOption {
      type = lib.types.str;
    };

    derpPort = lib.mkOption {
      type = lib.types.port;
      default = 3478;
    };
  };

  config = lib.mkIf cfg.enable {
    services.headscale = {
      enable = true;

      address = "0.0.0.0";
      port = 443;

      settings = {
        server_url = "https://${cfg.hostname}";

        dns = {
          base_domain = cfg.baseDomain;
          override_local_dns = false;
        };

        derp = {
          urls = [ ];

          server = {
            enabled = true;
            region_id = 999;
            region_code = "youn";
            region_name = "Youn";
            stun_listen_addr = "0.0.0.0:${toString cfg.derpPort}";
          };
        };

        tls_letsencrypt_hostname = cfg.hostname;
      };
    };

    networking.firewall = {
      allowedTCPPorts = [
        80
        443
      ];

      allowedUDPPorts = [ cfg.derpPort ];
    };
  };
}
