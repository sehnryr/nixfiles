{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.modules.zed-editor;

  enableNushellIntegration = config.modules.nushell.enable or false;
in
{
  options.modules.zed-editor = {
    enable = lib.mkEnableOption "";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.zed-zed-editor;
    };
    zedAlias = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    fonts = {
      monospace = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.submodule {
            options = {
              family = lib.mkOption { type = lib.types.str; };
            };
          }
        );
        default = null;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      package = cfg.package;
      installRemoteServer = true;
      extensions = [
        "html"
        "toml"
        "dockerfile"
        "git-firefly"
        "sql"
        "ruby"
        "make"
        "xml"
        "nix"
        "ruff"
        "deno"
        "proto"
        "scala"
        "nu"
        "wit"
        "scss"
        "angular"
      ];
      extraPackages = [
        pkgs.nil
        pkgs.nixd
        pkgs.nixfmt-rfc-style
        pkgs.ruff
      ];
      userSettings = lib.mkMerge [
        {
          show_edit_predictions = true;
          tab_size = 4;
          preferred_line_length = 100;
          soft_wrap = "editor_width";
          wrap_guides = [
            80
            100
          ];
          ui_font_size = 14;
          buffer_font_size = 14;
          format_on_save = "on";
          theme = {
            mode = "system";
            light = "One Light";
            dark = "Ayu Dark";
          };
          languages = {
            "YAML".tab_size = 2;
            "Ruby".tab_size = 2;
            "Python" = {
              language_servers = [ "ruff" ];
              formatter = [ { language_server.name = "ruff"; } ];
            };
            "Nix" = {
              tab_size = 2;
              formatter = [ { external.command = "nixfmt"; } ];
            };
          };
          assistant = {
            enabled = true;
            version = "2";
            default_model = {
              provider = "google";
              model = "gemini-2.5-pro-preview-05-06";
            };
          };
          language_models = {
            google = {
              available_models = [
                {
                  display_name = "Gemini 2.5 Pro Preview";
                  name = "gemini-2.5-pro-preview-05-06";
                  max_tokens = 1000000;
                }
              ];
            };
          };
        }
        (lib.mkIf (cfg.fonts.monospace != null) {
          buffer_font_family = cfg.fonts.monospace.family;
          terminal.font_family = cfg.fonts.monospace.family;
        })
        (lib.mkIf enableNushellIntegration {
          terminal.shell.program = "nu";
        })
      ];
    };

    home.shellAliases = lib.mkIf cfg.zedAlias {
      zed = "zeditor";
    };
  };
}
