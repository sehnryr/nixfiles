{
  modules = {
    cli.enable = true;
    dev.enable = true;
    security.enable = true;
    desktop = {
      enable = true;
      device = "laptop";
    };
    backup = {
      enable = true;
      folders = [
        ".claude/projects"
      ];
    };
  };

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
