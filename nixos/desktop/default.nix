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
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  documentation.doc.enable = false;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.kernelPatches =
    let
      commit = "bbf56029322c06a9227f09c2064f50278111159a";
      patchUrl = "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/patch/?id=${commit}";
      patchFile = pkgs.fetchurl {
        url = patchUrl;
        hash = "sha256-are5n1N5wwE+LZqbbi1ofENyliHH2bDNhV2DYiC0FZ4=";
      };
    in
    [
      {
        name = "Bluetooth: btusb: Add new VID/PID 13d3/3613 for MT7925";
        patch = patchFile;
      }
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-efba64ac-5927-4281-b972-4df09a479d35".device =
    "/dev/disk/by-uuid/efba64ac-5927-4281-b972-4df09a479d35";

  modules = {
    logind.enable = true;

    pipewire.enable = true;
  };

  networking.hostName = "desktop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.xserver.excludePackages = with pkgs; [ xterm ];

  services.gnome.core-apps.enable = false;
  services.gnome.localsearch.enable = false;
  services.gnome.tinysparql.enable = false;

  environment.gnome.excludePackages = with pkgs; [ gnome-tour ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };

  # Configure console keymap
  console.keyMap = "us-acentos";

  # Enable CUPS to print documents.
  services.printing.enable = false;

  services.fwupd.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user.name} = {
    isNormalUser = true;
    description = user.name;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = [ ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ lact ];
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lact.wantedBy = [ "multi-user.target" ];

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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
