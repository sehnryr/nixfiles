{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.backup;

  moduleNames = builtins.attrNames (builtins.readDir ./.);
  modules = builtins.map (name: ./. + ("/" + name)) moduleNames;
  filterOut = module: modules: builtins.filter (module': module' != module) modules;
in
{
  imports = filterOut ./default.nix modules;

  options.modules.backup = {
    enable = lib.mkEnableOption "backup";
  };

  config = lib.mkIf cfg.enable {
    services = {
      syncthing.enable = true;
    };
  };
}
