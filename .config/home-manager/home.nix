{ config, pkgs, ... }:

{
  home.username = "youn";
  home.homeDirectory = "/home/youn";

  home.stateVersion = "24.11";

  home.packages = [
    pkgs.cmake
    pkgs.bun
    pkgs.deno
    pkgs.starship
    pkgs.rustup
    pkgs.wget

    pkgs.python313Packages.pip
    pkgs.pipx

    pkgs.sccache

    pkgs.bruno

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  programs.home-manager.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.git = {
    enable = true;
    userName = "Youn Mélois";
    userEmail = "youn@melois.dev";
    signing = {
      format = "ssh";
      key = "/home/youn/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
    extraConfig = { init.defaultBranch = "main"; };
  };
}
