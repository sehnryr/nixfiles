{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.fwupd;
in
{
  options.modules.fwupd.enable = lib.mkEnableOption "fwupd";

  config = lib.mkIf cfg.enable {
    services.fwupd.enable = true;
  };
}
