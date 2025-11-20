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
      # 0640 root:onepassword-secrets
      tokenFile = "/etc/opnix-token";

      secrets = {
        context7ApiKey = {
          reference = "op://OpNix/Context7 API Key/credential";
          path = ".opnix/secrets/context7-api-key";
          mode = "0600";
          owner = "youn";
          group = "users";
        };
        githubPersonalAccessToken = {
          reference = "op://OpNix/Github Personal Access Token/credential";
          path = ".opnix/secrets/github-personal-access-token";
          mode = "0600";
          owner = "youn";
          group = "users";
        };
      };
    };
  };
}
