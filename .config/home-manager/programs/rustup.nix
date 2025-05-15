{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.modules.rustup;

  enableNushellIntegration = config.modules.nushell.enable or false;
  enableSccacheIntegration = config.modules.sccache.enable or false;
in
{
  options.modules.rustup = {
    enable = lib.mkEnableOption "";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.rustup
    ];

    home.file = lib.mkIf enableSccacheIntegration {
      ".cargo/config.toml" = {
        enable = true;
        text = ''
          [build]
          rustc-wrapper = "sccache"
        '';
      };
    };

    programs.nushell = lib.mkIf enableNushellIntegration {
      configFile.text = ''
        use std/util "path add"
        path add "${config.home.homeDirectory}/.cargo/bin"
      '';
    };
  };
}
