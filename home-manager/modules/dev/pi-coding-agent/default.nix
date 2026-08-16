{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.pi-coding-agent;

  wrappedPi = pkgs.symlinkJoin {
    name = "wrapped-pi";

    paths = [ pkgs.unstable.pi-coding-agent ];

    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      wrapProgram "$out/bin/pi" \
        --prefix PATH : ${lib.makeBinPath [ pkgs.nodejs ]} \
        --set PI_CACHE_RETENTION long
    '';
  };
in
{
  options.programs.pi-coding-agent.enable = lib.mkEnableOption "pi-coding-agent";

  config = lib.mkIf cfg.enable {
    home.packages = [ wrappedPi ];

    home.file.".pi/agent/settings.json" = {
      source = config.lib.file.mkRelativeOutOfStoreSymlink ./settings.json;
    };

    home.file.".pi/agent/models.json" = {
      source = config.lib.file.mkRelativeOutOfStoreSymlink ./models.json;
    };

    home.file.".pi/agent/AGENTS.md" = {
      source = config.lib.file.mkRelativeOutOfStoreSymlink ./AGENTS.md;
    };

    home.file.".pi/agent/extensions/writing-policy.ts" = {
      source = config.lib.file.mkRelativeOutOfStoreSymlink ./extensions/writing-policy.ts;
    };
  };
}
