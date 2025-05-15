{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.direnv;
in
{
  options.modules.direnv = {
    enable = lib.mkEnableOption "";
    enableNushellIntegration = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableNushellIntegration = cfg.enableNushellIntegration;
      nix-direnv.enable = true;
    };
  };
}
