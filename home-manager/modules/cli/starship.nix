{
  config,
  lib,
  ...
}:

let
  cfg = config.programs.starship;
in
{
  config = lib.mkIf cfg.enable {
    programs.starship = {
      settings = {
        scala.detect_folders = [ ];
      };
    };
  };
}
