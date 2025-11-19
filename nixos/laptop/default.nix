{
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  boot.initrd.luks.devices."luks-56c1d52e-92f4-4886-b1e6-0017ec4df4ca".device =
    "/dev/disk/by-uuid/56c1d52e-92f4-4886-b1e6-0017ec4df4ca";

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "1password"
      "1password-cli"
    ];

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
    fprintd.enable = true;

    # power management
    thermald.enable = true;
    tlp.enable = true;
  };

  networking.hostName = "laptop";
}
