{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.modules.sccache;
in
{
  options.modules.sccache = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.sccache
    ];
  };
}
