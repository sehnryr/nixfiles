{
  config,
  lib,
  ...
}:

let
  cfg = config.programs.onepassword-secrets;
in
{
  config = lib.mkIf cfg.enable {
    programs.onepassword-secrets = {
      # 0440 youn:onepassword-secrets
      tokenFile = "/etc/opnix-token";

      secrets = {
        context7ApiKey = {
          reference = "op://OpNix/Context7 API Key/credential";
          path = ".opnix/secrets/context7-api-key";
          mode = "0600";
          owner = "youn";
          group = "users";
        };
      };
    };
  };
}
