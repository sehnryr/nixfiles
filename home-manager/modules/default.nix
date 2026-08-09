{
  self,
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
    flakeDirectory = lib.mkOption {
      type = lib.types.path;
      default = "${config.home.homeDirectory}/nixfiles";
    };
    configDirectory = lib.mkOption {
      type = lib.types.path;
      default = "${config.user.flakeDirectory}/config";
    };
  };

  config = {
    home.username = user.name;
    home.homeDirectory = "/home/${user.name}";

    lib.file.mkRelativeOutOfStoreSymlink =
      path:
      let
        flakeDirectory = config.user.flakeDirectory;
        storeDirectory = toString self;
        pathStr = toString path;
      in
      config.lib.file.mkOutOfStoreSymlink "${flakeDirectory}/${lib.removePrefix "${storeDirectory}/" pathStr}";
  };
}
