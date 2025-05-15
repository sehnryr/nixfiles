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
    useSccache = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.rustup
      (lib.mkIf cfg.useSccache pkgs.sccache)
    ];

    home.file = lib.mkIf cfg.useSccache {
      ".cargo/config.toml" = {
        enable = true;
        text = ''
          [build]
          rustc-wrapper = "${pkgs.sccache}/bin/sccache"
        '';
      };
    };
  };
}
