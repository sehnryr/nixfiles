{
  config,
  lib,
  pkgs,
  ...
}:

let
  fonts = config.modules.fonts;
in
{
  options.modules.editors = {
    enable = lib.mkEnableOption "Editor configuration";
    enableNeovim = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Neovim configuration";
    };
    enableZed = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Zed editor configuration";
    };
  };

  config = lib.mkIf config.modules.editors.enable {
    programs.neovim = lib.mkIf config.modules.editors.enableNeovim {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    programs.zed-editor = lib.mkIf config.modules.editors.enableZed {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.zed-editor;
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
          terminal = {
            shell.program = "${pkgs.nushell}/bin/nu";
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
        (lib.mkIf fonts.enable {
          buffer_font_family = fonts.monospace.family;
          terminal = {
            font_family = fonts.monospace.family;
          };
        })
      ];
    };

    home.shellAliases = lib.mkIf config.modules.editors.enableZed {
      zed = "zeditor";
    };
  };
}
