{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.cli;

  moduleNames = builtins.attrNames (builtins.readDir ./.);
  modules = builtins.map (name: ./. + ("/" + name)) moduleNames;
  filterOut = module: modules: builtins.filter (module': module' != module) modules;
in
{
  imports = filterOut ./default.nix modules;

  options.modules.cli = {
    enable = lib.mkEnableOption "cli";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      bat.enable = true;
      carapace.enable = true;
      nushell.enable = true;
      starship.enable = true;
      nix-your-shell.enable = true;
    };

    home.shellAliases = {
      cat = "bat";
    };
  };
}
