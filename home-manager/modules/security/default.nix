{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.security;

  moduleNames = builtins.attrNames (builtins.readDir ./.);
  modules = builtins.map (name: ./. + ("/" + name)) moduleNames;
  filterOut = module: modules: builtins.filter (module': module' != module) modules;
in
{
  imports = filterOut ./default.nix modules;

  options.modules.security = {
    enable = lib.mkEnableOption "security";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      ssh.enable = true;
      onepassword-secrets.enable = true;
    };
  };
}
