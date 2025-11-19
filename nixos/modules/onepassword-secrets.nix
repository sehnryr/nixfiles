{
  config,
  lib,
  ...
}:

let
  cfg = config.services.onepassword-secrets;
in
{
  config = lib.mkIf cfg.enable {
    services.onepassword-secrets = {
      # 0440 youn:onepassword-secrets
      tokenFile = "/etc/opnix-token";

      secrets = {
        clamavNotificationApiCredential = {
          reference = "op://OpNix/ClamAV notification API/credential";
          mode = "0600";
          owner = "clamav";
          group = "clamav";
        };
        clamavNotificationApiUrl = {
          reference = "op://OpNix/ClamAV notification API/url";
          mode = "0600";
          owner = "clamav";
          group = "clamav";
        };
      };
    };
  };
}
