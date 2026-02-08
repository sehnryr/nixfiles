{
  config,
  lib,
  ...
}:

let
  cfg = config.programs.direnv;
in
{
  config = lib.mkIf cfg.enable {
    programs.direnv = {
      nix-direnv.enable = true;
      silent = true;
    };

    programs.git.ignores = lib.mkIf config.programs.git.enable [
      ".direnv/"
      ".envrc.local"
    ];
  };
}
