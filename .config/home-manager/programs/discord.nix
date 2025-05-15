{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.modules.discord;

  discordPackage = cfg.package.override { withOpenASAR = cfg.useOpenASAR; };

  krisp-patcher =
    pkgs.writers.writePython3Bin "krisp-patcher"
      {
        libraries = [
          pkgs.python3Packages.capstone
          pkgs.python3Packages.pyelftools
        ];
        flakeIgnore = [
          "E501" # line too long (82 > 79 characters)
          "F403" # 'from module import *' used; unable to detect undefined names
          "F405" # name may be undefined, or defined from star imports: module
        ];
      }
      (
        builtins.readFile (
          pkgs.fetchurl {
            url = "https://pastebin.com/raw/8tQDsMVd";
            sha256 = "sha256-IdXv0MfRG1/1pAAwHLS2+1NESFEz2uXrbSdvU9OvdJ8=";
          }
        )
      );
in
{
  options.modules.discord = {
    enable = lib.mkEnableOption "";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.discord;
    };
    useKrispPatcher = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    useOpenASAR = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      discordPackage
      (lib.mkIf cfg.useKrispPatcher krisp-patcher)
      (lib.mkIf cfg.useKrispPatcher pkgs.procps)
    ];

    home.activation.krispPatcher = lib.mkIf cfg.useKrispPatcher (
      lib.hm.dag.entryAfter [ "installPackages" ] ''
        discord_was_running=false
        if ${pkgs.procps}/bin/pgrep -f discord > /dev/null; then
          discord_was_running=true
          run ${pkgs.procps}/bin/pkill -f discord || true
        fi

        for node in "${config.xdg.configHome}/discord/"*"/modules/discord_krisp/discord_krisp.node"; do
          run ${krisp-patcher}/bin/krisp-patcher "$node"
        done

        if [ "$discord_was_running" = true ]; then
          run ${discordPackage}/bin/discord > /dev/null 2>&1 &
        fi
      ''
    );
  };
}
