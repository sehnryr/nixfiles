{
  pkgs,
  user,
  ...
}:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    ../../modules
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  zramSwap = {
    enable = true;
    memoryPercent = 200;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024; # MB
    }
  ];

  networking.hostName = "clever-cloud";

  networking.networkmanager.enable = true;

  modules = {
    store-tweaks.enable = true;
    logind.enable = true;
    _1password.enable = true;
    onepassword-secrets.enable = true;
    clamav.enable = true;
    pipewire.enable = true;
    gnome.enable = true;
    fonts.enable = true;
    libvirtd.enable = true;
    i18n.enable = true;
    fwupd.enable = true;
    tailscale.enable = true;
    # power management
    thermald.enable = true;
    tlp.enable = true;
  };

  time.timeZone = "Europe/Paris";

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

  system.stateVersion = "25.11";
}
