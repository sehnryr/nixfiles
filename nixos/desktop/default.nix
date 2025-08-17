{ pkgs, lib, ... }:

{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_16;

  boot.initrd.luks.devices."luks-efba64ac-5927-4281-b972-4df09a479d35".device =
    "/dev/disk/by-uuid/efba64ac-5927-4281-b972-4df09a479d35";

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
    ];

  programs = {
    steam.enable = true;
  };

  services = {
    printing.enable = true;
    mptcpd.enable = true;
  };

  networking.firewall.allowedUDPPorts = [
    # Warframe ports
    4950
    4955
  ];

  networking.hostName = "desktop";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.systemPackages = with pkgs; [ lact ];
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lact.wantedBy = [ "multi-user.target" ];
}
