{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.modules.discord;

  discordPackage = cfg.package.override { withOpenASAR = true; };

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
    enable = lib.mkEnableOption "enable discord";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.discord;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      discordPackage
    ];

    home.activation.krispPatcher = lib.hm.dag.entryAfter [ "installPackages" ] ''
      already_patched=false
      for node in "${config.xdg.configHome}/discord/"*"/modules/discord_krisp/discord_krisp.node"; do
        if [ ! -e "$node" ]; then continue; fi

        mkdir -p "$(dirname "/tmp/$node")"
        cp "$node" "/tmp/$node"

        command=$(run ${krisp-patcher}/bin/krisp-patcher "/tmp/$node")

        if [ "$command" = "Couldn't find patch location - already patched." ]; then
          rm "/tmp/$node"
          already_patched=true
        fi
      done

      if [ "$already_patched" = true ]; then
        exit 0
      fi

      discord_was_running=false
      if ${pkgs.procps}/bin/pgrep -f discord > /dev/null; then
        discord_was_running=true
        run ${pkgs.procps}/bin/pkill -f discord || true
      fi

      for node in "${config.xdg.configHome}/discord/"*"/modules/discord_krisp/discord_krisp.node"; do
        if [ ! -e "$node" ]; then continue; fi
        run cp "/tmp/$node" "$node"
        rm "/tmp/$node"
      done

      if [ "$discord_was_running" = true ]; then
        run ${discordPackage}/bin/discord > /dev/null 2>&1 &
      fi
    '';
  };
}
