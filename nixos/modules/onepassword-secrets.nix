{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.modules.onepassword-secrets;
in
{
  options.modules.onepassword-secrets.enable = lib.mkEnableOption "OpNix";

  config = lib.mkIf cfg.enable {
    users.users.${user.name} = {
      extraGroups = [ "onepassword-secrets" ];
    };

    services.onepassword-secrets = {
      enable = true;
      # 0640 root:onepassword-secrets
      tokenFile = "/etc/opnix-token";

      secrets = {
        clamavNotificationApiCredential = lib.mkIf config.modules.clamav.enable {
          reference = "op://OpNix/ClamAV notification API/credential";
          mode = "0600";
          owner = "clamav";
          group = "clamav";
        };
        clamavNotificationApiUrl = lib.mkIf config.modules.clamav.enable {
          reference = "op://OpNix/ClamAV notification API/url";
          mode = "0600";
          owner = "clamav";
          group = "clamav";
        };
      };
    };
  };
}
