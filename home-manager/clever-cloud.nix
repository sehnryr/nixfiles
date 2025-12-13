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
  };

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
