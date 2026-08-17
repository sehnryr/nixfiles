{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.pi-web;
  agentTools = import ./pi-coding-agent/agent-tools.nix { inherit pkgs; };

  wrappedPiWeb = pkgs.symlinkJoin {
    name = "wrapped-pi-web";

    paths = [ pkgs.pi-web ];

    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      wrapProgram "$out/bin/pi-web" \
        --prefix PATH : ${lib.makeBinPath agentTools}
    '';
  };
in
{
  options.programs.pi-web = {
    enable = lib.mkEnableOption "pi-web service";

    port = lib.mkOption {
      type = lib.types.port;
      default = 30141;
      description = "Port on which pi-web listens.";
    };

    allowedHosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "desktop.youn.internal" ];
      description = "Additional hostnames accepted by pi-web.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ wrappedPiWeb ];

    systemd.user.services.pi-web = {
      Unit = {
        Description = "Pi Web interface";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Environment = "PI_WEB_ALLOWED_HOSTS=${lib.concatStringsSep "," cfg.allowedHosts}";
        ExecStart = "${lib.getExe' wrappedPiWeb "pi-web"} --hostname 0.0.0.0 --port ${toString cfg.port} --no-open";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install.WantedBy = [ "default.target" ];
    };

  };
}
