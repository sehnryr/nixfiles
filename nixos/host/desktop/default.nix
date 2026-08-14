{
  pkgs,
  user,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
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

  networking.hostName = "desktop";

  networking.networkmanager.enable = true;

  environment.systemPackages = [
    pkgs.unstable.signal-desktop
  ];

  programs.nix-ld.enable = true;

  modules = {
    store-tweaks.enable = true;
    nix-cache.enable = true;
    logind.enable = true;
    _1password.enable = true;
    age.enable = true;
    pipewire.enable = true;
    gnome.enable = true;
    fonts.enable = true;
    libvirtd.enable = true;
    i18n.enable = true;
    fwupd.enable = true;
    mptcpd.enable = true;
    steam.enable = true;
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

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  hardware.amdgpu.overdrive.enable = true;

  services.lact.enable = true;

  boot.initrd.luks.devices."luks-efba64ac-5927-4281-b972-4df09a479d35".device =
    "/dev/disk/by-uuid/efba64ac-5927-4281-b972-4df09a479d35";

  system.stateVersion = "26.05";
}
