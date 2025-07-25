{
  pkgs,
  lib,
  user,
  ...
}:

{
  home.username = user.name;
  home.homeDirectory = user.homeDirectory;

  home.stateVersion = "25.05";

  home.file = {
    ".ssh/master.pub" = {
      enable = lib.mkDefault false;
      text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFPO/hKBeNBJVbq8yPL13KRBLCn+gpXyNtAs1UyvyP9Z";
    };

    ".ssh/clever-cloud.pub" = {
      enable = lib.mkDefault false;
      text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID1krg5H1ekYVacZPCKvYARdBy4JT5M+fGo2EFvJD0n4";
    };

    ".ssh/arch-user-repository.pub" = {
      enable = lib.mkDefault false;
      text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEDJ8D1zFG29hHuE5uJk1W5D+UrmhYlUYks8MvLtZQoa";
    };
  };

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
    jujutsu.enable = true;
    direnv.enable = true;
    neovim.enable = true;
    nushell.enable = true;
    sccache.enable = true;
    carapace.enable = true;
    starship.enable = true;
  };

  programs.home-manager.enable = true;
}
