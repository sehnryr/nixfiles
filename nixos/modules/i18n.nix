{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.i18n;
in
{
  options.modules.i18n.enable = lib.mkEnableOption "Locale settings";

  config = lib.mkIf cfg.enable {
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    # GTK 4.20 onwards removed compose keys and dead key handling.
    # We need to provide a proper input method for handling those.
    # https://github.com/ghostty-org/ghostty/discussions/8899#discussioncomment-14717979
    i18n.inputMethod = {
      enable = true;
      type = "ibus";
    };

    services.xserver.xkb = {
      layout = "us";
      variant = "intl";
    };

    console.keyMap = "us-acentos";

  };
}
