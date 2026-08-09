{
  config,
  lib,
  ...
}:

let
  cfg = config.services.syncthing;
in
{
  options.services.syncthing = {
    folders = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      overrideDevices = false;
      settings = {
        gui.enable = true;
        devices = {
          "youn::server" = {
            id = "YOAVET3-W4BYA35-FIOS6XX-2R7KJLI-TDDDTOT-YMTDHRW-65BMHZE-D36Y6A5";
            introducer = true;
          };
        };
        folders = builtins.listToAttrs (
          map (
            folder:
            let
              fullPath = "${config.home.homeDirectory}/${folder}";
              dashed = builtins.replaceStrings [ "/" " " ] [ "-" "-" ] fullPath;
              stripped =
                let
                  chars = lib.stringToCharacters dashed;
                  rest = lib.lists.findFirstIndex (c: c != "-" && c != "/") null chars;
                in
                if rest == null then "" else builtins.substring rest (builtins.stringLength dashed) dashed;
            in
            {
              name = stripped;
              value = {
                path = fullPath;
                devices = [ "youn::server" ];
              };
            }
          ) cfg.folders
        );
      };
    };

    xdg.desktopEntries.syncthing-ui = {
      name = "";
      noDisplay = true;
    };
  };
}
