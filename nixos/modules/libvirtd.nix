{
  config,
  pkgs,
  lib,
  user,
  ...
}:

let
  cfg = config.virtualisation.libvirtd;
in
{
  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = {
      qemu.vhostUserPackages = [ pkgs.virtiofsd ];
    };

    users.users.${user.name} = {
      extraGroups = [
        "libvirtd"
      ];
    };
  };
}
