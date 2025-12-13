{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.gaming;

  moduleNames = builtins.attrNames (builtins.readDir ./.);
  modules = builtins.map (name: ./. + ("/" + name)) moduleNames;
  filterOut = module: modules: builtins.filter (module': module' != module) modules;
in
{
  imports = filterOut ./default.nix modules;

  options.modules.gaming = {
    enable = lib.mkEnableOption "gaming";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      prismlauncher.enable = true;
    };
  };
}
