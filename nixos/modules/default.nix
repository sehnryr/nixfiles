let
  moduleNames = builtins.attrNames (builtins.readDir ./.);
  modules = map (name: ./. + ("/" + name)) moduleNames;
  filterOut = module: modules: builtins.filter (module': module' != module) modules;
in
{
  imports = filterOut ./default.nix modules;
}
