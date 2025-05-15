{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.modules.cargo-binstall;
in
{
  options.modules.cargo-binstall = {
    enable = lib.mkEnableOption "";
    enableNushellIntegration = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.cargo-binstall
    ];

    programs.nushell = lib.mkIf cfg.enableNushellIntegration {
      environmentVariables.BINSTALL_NO_CONFIRM = "";
    };
  };
}
