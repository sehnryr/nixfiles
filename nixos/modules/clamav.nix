{
  config,
  pkgs,
  lib,
  user,
  ...
}:

let
  cfg = config.services.clamav;

  clamavNotificationApiCredentialFile =
    config.services.onepassword-secrets.secretPaths."clamavNotificationApiCredential";
  clamavNotificationApiUrlFile =
    config.services.onepassword-secrets.secretPaths."clamavNotificationApiUrl";

  clamavNotify = pkgs.writeShellScript "clamav-notify-cc.sh" ''
    function check_variables () {
      if [[ -z "''${CLAM_VIRUSEVENT_FILENAME}" || -z "''${CLAM_VIRUSEVENT_VIRUSNAME}" ]]; then
        echo "Unexpected input"
        exit 1
      fi
    }

    function do_notify () {
      local virus_name="''${CLAM_VIRUSEVENT_VIRUSNAME}"
      local filename="''${CLAM_VIRUSEVENT_FILENAME}"
      local user="$(${pkgs.coreutils}/bin/whoami)"
      local fqdn="$(${pkgs.hostname}/bin/hostname -f)"
      echo "Virus detection notification sent at: $(${pkgs.coreutils}/bin/date)"
      ${pkgs.curl}/bin/curl "$(${pkgs.coreutils}/bin/cat ${clamavNotificationApiUrlFile})" \
        --user "$(${pkgs.coreutils}/bin/cat ${clamavNotificationApiCredentialFile})" \
        --json "{\"virus\":\"''${virus_name}\",\"file\":\"''${filename}\",\"user\":\"''${user}\",\"host\":\"''${fqdn}\"}"
    }

    function main () {
      check_variables
      do_notify
    }

    main
  '';
in
{
  options.services.clamav = {
    enable = lib.mkEnableOption "clamav";
  };

  config = lib.mkIf cfg.enable {
    services.clamav = {
      daemon = {
        enable = true;
        settings = {
          OnAccessExcludeUname = "clamav";
          OnAccessIncludePath = "${user.homeDirectory}/Downloads";
          VirusEvent = "${clamavNotify}";
        };
      };
      updater.enable = true;
    };

    systemd.services.clamav-freshclam.wants = [ "network-online.target" ];

    systemd.services.clamav-daemon = {
      serviceConfig = pkgs.lib.mkForce {
        ExecStart = "${cfg.package}/bin/clamd";
        ExecReload = "${pkgs.coreutils}/bin/kill -USR2 $MAINPID";
        User = "clamav";
        Group = "clamav";
        StateDirectory = "clamav";
        RuntimeDirectory = "clamav";
        PrivateNetwork = "no";
      };
    };

    systemd.services.clamav-clamonacc = {
      unitConfig = {
        Description = "ClamAV daemon for on-access scanning";
        Wants = "network-online.target";
        After = "network-online.target syslog.target";
        Requires = "clamav-daemon.service";
      };
      serviceConfig = {
        Type = "simple";
        ExecStartPre = [
          "${pkgs.bash}/bin/bash -c 'while [ ! -S /run/clamav/clamd.ctl ]; do ${pkgs.coreutils}/bin/sleep 1; done'"
          "${pkgs.coreutils}/bin/mkdir -p /var/lib/clamav/quarantine"
        ];
        ExecStart = "${cfg.package}/bin/clamonacc --foreground --stream --move=/var/lib/clamav/quarantine";
        Restart = "on-failure";
      };
      wantedBy = [ "multi-user.target" ];
    };

  };
}
