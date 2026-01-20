# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  lib,
  user,
  fonts,
  ...
}:

{
  documentation.doc.enable = false;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services = {
    printing.enable = lib.mkDefault false;
    pipewire.enable = true;
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.excludePackages = with pkgs; [ xterm ];

  services.gnome.core-apps.enable = false;
  services.gnome.localsearch.enable = false;
  services.gnome.tinysparql.enable = false;

  environment.gnome.excludePackages = with pkgs; [ gnome-tour ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };

  # Configure console keymap
  console.keyMap = "us-acentos";

  services.fwupd.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user.name} = {
    isNormalUser = true;
    description = user.name;
    shell = pkgs.nushell;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = [ ];
  };

  fonts =
    let
      getFonts = fonts: value: lib.mapAttrsToList (_: font: font.${value}) fonts;

      fontsSans = getFonts fonts.sans;
      fontsSerif = getFonts fonts.serif;
      fontsMonospace = getFonts fonts.monospace;
      fontsEmoji = getFonts fonts.emoji;
    in
    {
      packages =
        (fontsSans "package")
        ++ (fontsSerif "package")
        ++ (fontsMonospace "package")
        ++ (fontsEmoji "package");
      fontconfig = {
        enable = true;
        defaultFonts = {
          sansSerif = fontsSans "family";
          serif = fontsSerif "family";
          monospace = fontsMonospace "family";
          emoji = fontsEmoji "family";
        };
      };
    };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
