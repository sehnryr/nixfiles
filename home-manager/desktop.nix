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
      device = "desktop";
    };
    gaming.enable = true;
    backup = {
      enable = true;
      folders = [
        ".claude/projects"
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
