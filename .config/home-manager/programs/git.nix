{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.modules.git;
in
{
  options.modules.git = {
    enable = lib.mkEnableOption "Git configuration";
    user = {
      name = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      email = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    };
    signing = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.submodule {
          options = {
            format = lib.mkOption {
              type = lib.types.enum [
                "ssh"
                "gpg"
              ];
            };
            key = lib.mkOption { type = lib.types.str; };
          };
        }
      );
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      # git log pager
      pkgs.less
    ];

    programs.git = lib.mkMerge [
      {
        enable = true;
        signing.signByDefault = true;
        extraConfig.init.defaultBranch = "main";
      }
      (lib.mkIf (cfg.user.name != null) {
        userName = cfg.user.name;
      })
      (lib.mkIf (cfg.user.email != null) {
        userEmail = cfg.user.email;
      })
      (lib.mkIf (cfg.signing != null) {
        signing = {
          format = cfg.signing.format;
          key = builtins.toString cfg.signing.key;
        };
      })
    ];
  };
}
