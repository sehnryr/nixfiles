{
  pkgs,
  ...
}:

{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_18;

  boot.initrd.luks.devices."luks-efba64ac-5927-4281-b972-4df09a479d35".device =
    "/dev/disk/by-uuid/efba64ac-5927-4281-b972-4df09a479d35";

  environment.systemPackages = with pkgs; [
    signal-desktop
  ];

  programs = {
    _1password.enable = true;
    steam.enable = true;
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        openssl
      ];
    };
  };

  services = {
    logind.enable = true;
    clamav.enable = true;
    onepassword-secrets.enable = true;
    printing.enable = true;
    mptcpd.enable = true;
  };

  virtualisation = {
    libvirtd.enable = true;
  };

  networking.hostName = "desktop";

  networking.firewall.allowedTCPPorts = [ 50080 ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.amdgpu.overdrive.enable = true;

  services.lact = {
    enable = true;
  };
}
