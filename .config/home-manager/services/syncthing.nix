{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.syncthing;
in
{
  options.modules.syncthing = {
    enable = lib.mkEnableOption "";
    introducer = {
      id = lib.mkOption { type = lib.types.str; };
      name = lib.mkOption {
        type = lib.types.str;
        default = "node-0";
      };
    };
    folders = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            id = lib.mkOption { type = lib.types.str; };
            path = lib.mkOption { type = lib.types.str; };
          };
        }
      );
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      settings = {
        devices = {
          "${cfg.introducer.name}" = {
            id = cfg.introducer.id;
            introducer = true;
          };
        };
        folders = lib.mapAttrs (
          name:
          { id, path }:
          {
            enable = true;
            id = id;
            path = path;
            devices = [ "${cfg.introducer.name}" ];
          }
        ) cfg.folders;
      };
    };
  };
}
