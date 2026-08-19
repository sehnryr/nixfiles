{
  pkgs,
  user,
  ...
}:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    "auto-allocate-uids"
    "cgroups"
  ];

  nix.settings.auto-allocate-uids = true;
  nix.settings.system-features = [
    "uid-range"
    "devnet"
  ];
  nix.settings.extra-sandbox-paths = [
    "/dev/net"
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

  programs.nix-ld.enable = true;

  modules = {
    store-tweaks.enable = true;
    nix-cache.enable = true;
    logind.enable = true;
    _1password.enable = true;
    age.enable = true;
    clamav.enable = true;
    osquery.enable = true;
    pipewire.enable = true;
    gnome.enable = true;
    fonts.enable = true;
    libvirtd.enable = true;
    i18n.enable = true;
    fwupd.enable = true;

    tailscale = {
      enable = true;
      loginServer = "https://headscale.corp.clever.cloud";
      useAuthKey = false;
      trustTailnet = false;
    };

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

  system.stateVersion = "26.05";
}
