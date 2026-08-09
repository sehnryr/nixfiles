{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.modules.age;
in
{
  options.modules.age.enable = lib.mkEnableOption "Age";

  config = lib.mkIf cfg.enable {
    users.groups."agesecrets".members = [ user.name ];

    systemd.tmpfiles.rules = [
      "z /etc/age/key.txt 0640 root agesecrets - -"
    ];

    age = {
      identityPaths = [ "/etc/age/key.txt" ];
      secrets = {
        clamavNotifyUrl.file = ../../secrets/clamav-notify-url.age;
        clamavNotifyCredential.file = ../../secrets/clamav-notify-credential.age;
      };
    };
  };
}
