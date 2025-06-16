{
  pkgs,
  user,
  ...
}:

{
  home.username = user.name;
  home.homeDirectory = user.homeDirectory;

  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    # cli
    tealdeer

    # gui
    nautilus # gnome file manager
    evince # gnome document viewer
    loupe # gnome image viewer
    gnome-disk-utility
    gnome-calculator
    libreoffice-fresh
    resources
    vlc
  ];

  modules = {
    # cli
    ssh.enable = true;
    git.enable = true;
    direnv.enable = true;
    neovim.enable = true;
    nushell.enable = true;
    sccache.enable = true;
    carapace.enable = true;
    starship.enable = true;
  };

  programs.home-manager.enable = true;
}
