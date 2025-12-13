{
  config,
  lib,
  fonts,
  ...
}:

let
  cfg = config.programs.ghostty;
in
{
  options.programs.ghostty = {
    enableNushellIntegration = lib.mkOption {
      type = lib.types.bool;
      default = config.home.shell.enableNushellIntegration;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = lib.mkMerge [
      {
        settings = {
          theme = "light:Monokai Pro Light,dark:Monokai Pro";
          resize-overlay = "never";
          font-family = fonts.monospace.default.family;
          font-size = 10;
        };
      }
      (lib.mkIf cfg.enableNushellIntegration {
        settings = {
          command = "${config.programs.nushell.package}/bin/nu";
        };
      })
    ];
  };
}
