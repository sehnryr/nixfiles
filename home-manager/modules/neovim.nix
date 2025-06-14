{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.neovim;

  nushellEnabled = config.modules.nushell.enable or false;
in
{
  options.modules.neovim = {
    enable = lib.mkEnableOption "enable neovim";
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    programs.nushell.environmentVariables = lib.mkIf nushellEnabled {
      EDITOR = "nvim";
    };

    xdg.desktopEntries.nvim = {
      name = "";
      noDisplay = true;
    };
  };
}
