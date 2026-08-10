{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.osquery;
in
{
  options.modules.osquery.enable = lib.mkEnableOption "osquery";

  config = lib.mkIf cfg.enable {
    modules.age.enable = true;
    age.secrets = {
      osqueryFleetCert.file = ../../secrets/fleet.pem.age;
      osqueryEnrollSecret.file = ../../secrets/secret.txt.age;
      osqueryFlags.file = ../../secrets/osquery.flags.age;
    };

    services.osquery = {
      enable = true;
      flags = {
        tls_server_certs = config.age.secrets.osqueryFleetCert.path;
        enroll_secret_path = config.age.secrets.osqueryEnrollSecret.path;
        flagfile = config.age.secrets.osqueryFlags.path;
      };
    };
  };
}
