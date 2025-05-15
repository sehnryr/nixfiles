{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.modules.cargo-binstall;

  enableNushellIntegration = config.modules.nushell.enable or false;
in
{
  options.modules.cargo-binstall = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.cargo-binstall
    ];

    programs.nushell = lib.mkIf enableNushellIntegration {
      environmentVariables.BINSTALL_NO_CONFIRM = "";
    };
  };
}
