{
  config,
  lib,
  user,
  ...
}:

let
  cfg = config.programs._1password;
in
{
  config = lib.mkIf cfg.enable {
    programs._1password-gui = {
      enable = lib.mkDefault true;
      polkitPolicyOwners = lib.mkDefault [ user.name ];
    };

    environment.etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          zen
        '';
        mode = "0755";
      };
    };

    services.onepassword-secrets = {
      enable = true;
      # 0640 root:onepassword-secrets
      tokenFile = "/etc/opnix-token";

      secrets = {
        clamavNotificationApiCredential = {
          reference = "op://OpNix/ClamAV notification API/credential";
          owner = "clamav";
          group = "clamav";
        };
        clamavNotificationApiUrl = {
          reference = "op://OpNix/ClamAV notification API/url";
          owner = "clamav";
          group = "clamav";
        };
      };
    };
  };
}
