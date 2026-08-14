{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    jdk21_headless
    minecraft-server-manager
  ];

  users.users."minecraft" = {
    isSystemUser = true;
    group = "minecraft";
    home = "/srv/minecraft";
    createHome = true;
  };

  users.groups."minecraft" = { };

  services.minecraft = {
    enable = true;
  };

  networking.firewall = {
    allowedTCPPortRanges = [
      {
        from = 25000;
        to = 30000;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 25000;
        to = 30000;
      }
    ];
  };
}
