{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.thermald;
in
{
  options.modules.thermald = {
    enable = lib.mkEnableOption "enable thermald";
  };

  config = lib.mkIf cfg.enable {
    services.thermald.enable = true;
  };
}
