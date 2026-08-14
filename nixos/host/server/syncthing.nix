{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    overrideDevices = true;
    overrideFolders = false;
    settings = {
      gui.enabled = true;
      options = {
        announceLANAddresses = false;
        localAnnounceEnabled = false;
        natEnabled = false;
      };
      devices = {
        "youn::desktop" = {
          id = "XISPYUG-DNTVMB2-PHCHRCI-TMOTNJR-GJSK7LZ-6N4LN5P-GK6SISC-U43A2AD";
        };
        "youn::framework" = {
          id = "KTQFQBS-PJBRNJU-NYWCB4W-OFQJO7S-PDWZ2P2-SVVRTEP-IPLQNUQ-L4PSUA5";
        };
        "youn::oneplus7" = {
          id = "NGOR4WN-XNI2KM2-ANKJULP-B3ERFIJ-JPVLYM3-IG6DISL-PXU6JQD-2EH2FAZ";
        };
        "youn::fairphone6" = {
          id = "DRY377T-W3QX2H6-QWCMAAJ-JHJHW4F-RNZ6ZNE-GE7PHGW-G7ZZPWZ-RDOCNQM";
        };
        "clever-cloud::thinkpad" = {
          id = "UBQQYMZ-NWAYHOM-PBYLAAC-VBTJAE7-USBJNMD-VZWLWNW-64DHPXQ-HSURVAF";
        };
      };
    };
  };
}
