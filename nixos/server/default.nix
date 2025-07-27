{
  modulesPath,
  ssh,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  users.users."root" = {
    openssh.authorizedKeys.keys = [ ssh.public.text ];
  };

  services.openssh.enable = true;

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    overrideDevices = false;
    overrideFolders = false;
    settings = {
      gui.enabled = false;
      options = {
        announceLANAddresses = false;
        localAnnounceEnabled = false;
        natEnabled = false;
      };
      devices = {
        "desktop" = {
          id = "XISPYUG-DNTVMB2-PHCHRCI-TMOTNJR-GJSK7LZ-6N4LN5P-GK6SISC-U43A2AD";
          autoAcceptFolders = true;
        };
        "laptop" = {
          id = "KTQFQBS-PJBRNJU-NYWCB4W-OFQJO7S-PDWZ2P2-SVVRTEP-IPLQNUQ-L4PSUA5";
          autoAcceptFolders = true;
        };
        "mobile" = {
          id = "C5FRWWE-HZQ2H7F-RO522LK-Q4JIGZL-ET6LZMT-CL737LK-A7LRPUW-OBWYQAC";
          autoAcceptFolders = true;
        };
      };
    };
  };

  system.stateVersion = "25.05";
}
