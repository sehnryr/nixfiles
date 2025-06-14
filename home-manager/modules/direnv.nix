{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.direnv;

  nushellEnabled = config.modules.nushell.enable or false;
in
{
  options.modules.direnv = {
    enable = lib.mkEnableOption "enable direnv";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableNushellIntegration = nushellEnabled;
      nix-direnv.enable = true;
    };
  };
}
