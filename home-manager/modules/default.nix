{
  config,
  lib,
  user,
  ...
}:
let
  moduleNames = builtins.attrNames (builtins.readDir ./.);
  modules = map (name: ./. + ("/" + name)) moduleNames;
  filterOut = module: modules: builtins.filter (module': module' != module) modules;
in
{
  imports = filterOut ./default.nix modules;

  options.user = {
    configDirectory = lib.mkOption {
      type = lib.types.path;
      default = "${config.home.homeDirectory}/nixfiles/config";
    };
  };

  config = {
    home.username = user.name;
    home.homeDirectory = "/home/${user.name}";
  };
}
