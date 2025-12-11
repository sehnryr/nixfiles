{
  pkgs,
  ...
}:

{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  boot.initrd.luks.devices."luks-aa53b969-2e9f-4f51-be2e-010aea5bde1f".device =
    "/dev/disk/by-uuid/aa53b969-2e9f-4f51-be2e-010aea5bde1f";

  programs = {
    _1password.enable = true;
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        openssl
      ];
    };
  };

  services = {
    clamav.enable = true;
    onepassword-secrets.enable = true;
    osquery = {
      enable = true;
      flags.flagfile = "/etc/osquery/osquery.flags";
    };
    # power management
    thermald.enable = true;
    tlp.enable = true;
  };

  virtualisation = {
    libvirtd.enable = true;
  };

  networking.hostName = "clever-cloud";
}
