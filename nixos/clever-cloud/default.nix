{ ... }:

{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  boot.initrd.luks.devices."luks-aa53b969-2e9f-4f51-be2e-010aea5bde1f".device =
    "/dev/disk/by-uuid/aa53b969-2e9f-4f51-be2e-010aea5bde1f";

  modules = {
    # power management
    thermald.enable = true;
    tlp.enable = true;
  };

  networking.hostName = "clever-cloud";

  # Enable CUPS to print documents.
  services.printing.enable = false;

}
