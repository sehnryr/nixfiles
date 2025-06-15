{
  config,
  lib,
  user,
  ...
}:

let
  cfg = config.modules.nh;

  nushellEnabled = config.modules.nushell.enable or false;
in
{
  options.modules.nh = {
    enable = lib.mkEnableOption "enable nh";
  };

  config = lib.mkIf cfg.enable {
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep 5 --keep-since 3d";
      };
      flake = user.nixConfigDirectory;
    };

    programs.nushell.environmentVariables = lib.mkIf nushellEnabled {
      NH_FLAKE = user.nixConfigDirectory;
    };
  };
}
