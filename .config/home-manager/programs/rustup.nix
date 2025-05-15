{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.modules.rustup;
in
{
  options.modules.rustup = {
    enable = lib.mkEnableOption "";
    enableSccacheIntegration = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    enableNushellIntegration = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.rustup
    ];

    home.file = lib.mkIf cfg.enableSccacheIntegration {
      ".cargo/config.toml" = {
        enable = true;
        text = ''
          [build]
          rustc-wrapper = "sccache"
        '';
      };
    };

    programs.nushell = lib.mkIf cfg.enableNushellIntegration {
      configFile.text = ''
        use std/util "path add"
        path add "${config.home.homeDirectory}/.cargo/bin"
      '';
    };
  };
}
