{
  config,
  pkgs,
  lib,
  user,
  ...
}:
let
  cfg = config.modules.libvirtd;
in
{
  options.modules.libvirtd.enable = lib.mkEnableOption "libvirtd";

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu.vhostUserPackages = [ pkgs.virtiofsd ];
    };

    users.users.${user.name} = {
      extraGroups = [
        "libvirtd"
      ];
    };
  };
}
