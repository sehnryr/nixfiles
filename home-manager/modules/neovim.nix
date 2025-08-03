{
  config,
  lib,
  ...
}:

let
  cfg = config.programs.neovim;
in
{
  config = lib.mkIf cfg.enable {
    programs.neovim = {
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    xdg.desktopEntries.nvim = {
      name = "";
      noDisplay = true;
    };
  };
}
