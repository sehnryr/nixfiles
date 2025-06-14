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
    enable = lib.mkEnableOption "enable sccache";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.sccache
    ];

    home.file = {
      ".cargo/config.toml" = {
        enable = true;
        text = lib.generators.toTOML {
          build = {
            rustc-wrapper = "${pkgs.sccache}/bin/sccache";
          };
        };
      };
    };
  };
}
