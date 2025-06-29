{ pkgs, lib, ... }:

{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  boot.kernelPatches =
    let
      commit = "bbf56029322c06a9227f09c2064f50278111159a";
      patchUrl = "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/patch/?id=${commit}";
      patchFile = pkgs.fetchurl {
        url = patchUrl;
        hash = "sha256-are5n1N5wwE+LZqbbi1ofENyliHH2bDNhV2DYiC0FZ4=";
      };
    in
    [
      {
        name = "Bluetooth: btusb: Add new VID/PID 13d3/3613 for MT7925";
        patch = patchFile;
      }
    ];

  boot.initrd.luks.devices."luks-efba64ac-5927-4281-b972-4df09a479d35".device =
    "/dev/disk/by-uuid/efba64ac-5927-4281-b972-4df09a479d35";

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
    ];

  modules = {
    steam.enable = true;
  };

  networking.hostName = "desktop";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  environment.systemPackages = with pkgs; [ lact ];
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lact.wantedBy = [ "multi-user.target" ];

  # Enable Multipath TCP
  services.mptcpd.enable = true;
  boot.kernel.sysctl = {
    "net.mptcp.enabled" = "1";
  };
}
