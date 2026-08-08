{
  user,
  ...
}:

{
  home.username = user.name;
  home.homeDirectory = user.homeDirectory;

  modules = {
    cli.enable = true;
    dev.enable = true;
    security.enable = true;
    desktop = {
      enable = true;
      device = "laptop";
    };
    gaming.enable = true;
    backup = {
      enable = true;
      folders = [
        "Backups"
        "Desktop"
        "Pictures"
        "Videos"
      ];
    };
  };

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
