{
  services.syncthing = {
    enable = true;
    openDefaultPorts = false;

    overrideDevices = false;
    overrideFolders = false;

    guiAddress = "0.0.0.0:8384";

    settings = {
      gui.enabled = true;
      options = {
        announceLANAddresses = false;
        localAnnounceEnabled = false;
        globalAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
      };
    };
  };

  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [
      8384
      22000
    ];
    allowedUDPPorts = [ 22000 ];
  };
}
