{
  pkgs,
  user,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "laptop";

  networking.networkmanager.enable = true;

  documentation.doc.enable = false;

  environment.systemPackages = [
    pkgs.unstable.signal-desktop
  ];

  programs.nix-ld.enable = true;

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
    steam.enable = true;
    fprintd.enable = true;

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

  boot.initrd.luks.devices."luks-56c1d52e-92f4-4886-b1e6-0017ec4df4ca".device =
    "/dev/disk/by-uuid/56c1d52e-92f4-4886-b1e6-0017ec4df4ca";

  system.stateVersion = "26.05";
}
