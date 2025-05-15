{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.neovim;
in
{
  options.modules.neovim = {
    enable = lib.mkEnableOption "";
    viAlias = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    vimAlias = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = cfg.viAlias;
      vimAlias = cfg.vimAlias;
    };
  };
}
