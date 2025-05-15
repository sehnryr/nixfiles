{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.direnv;

  enableNushellIntegration = config.modules.nushell.enable or false;
in
{
  options.modules.direnv = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableNushellIntegration = enableNushellIntegration;
      nix-direnv.enable = true;
    };
  };
}
