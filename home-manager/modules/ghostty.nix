{
  config,
  lib,
  fonts,
  ...
}:

let
  cfg = config.modules.ghostty;

  nushellEnabled = config.modules.nushell.enable or false;
in
{
  options.modules.ghostty = {
    enable = lib.mkEnableOption "enable ghostty";
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = lib.mkMerge [
      {
        enable = true;
        settings = {
          theme = "light:Monokai Pro Light,dark:Monokai Pro";
          resize-overlay = "never";
          font-family = fonts.monospace.default.family;
          font-size = 10;
        };
      }
      (lib.mkIf nushellEnabled {
        settings = {
          command = "nu";
        };
      })
    ];
  };
}
