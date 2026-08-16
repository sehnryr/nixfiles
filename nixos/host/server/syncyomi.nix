{
  pkgs,
  ...
}:
{
  users.users.syncyomi = {
    isSystemUser = true;
    group = "syncyomi";
    home = "/var/lib/syncyomi";
  };

  users.groups."syncyomi" = { };

  systemd.services.syncyomi = {
    description = "SyncYomi server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      User = "syncyomi";
      Group = "syncyomi";

      StateDirectory = "syncyomi";
      WorkingDirectory = "/var/lib/syncyomi";

      ExecStart = "${pkgs.unstable.syncyomi}/bin/syncyomi --config=/var/lib/syncyomi";

      Restart = "on-failure";
      RestartSec = 5;

      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
    };
  };

  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [ 8282 ];
  };
}
