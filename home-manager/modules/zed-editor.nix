{
  config,
  pkgs,
  lib,
  fonts,
  ...
}:

let
  cfg = config.programs.zed-editor;
in
{
  options.programs.zed-editor = {
    enableNushellIntegration = lib.mkOption {
      type = lib.types.bool;
      default = config.home.shell.enableNushellIntegration;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      package = pkgs.zed-editor-fhs;
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
        "mcp-server-context7"
        "java"
      ];
      extraPackages = with pkgs; [
        nil
        nixd
        nixfmt-rfc-style
        ruff
        jdt-language-server
        metals
        bloop
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
          buffer_font_family = fonts.monospace.default.family;
          terminal.font_family = fonts.monospace.default.family;
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
              language_servers = [
                "pyright"
                "ruff"
              ];
              formatter = [ { language_server.name = "ruff"; } ];
            };
            "Nix" = {
              tab_size = 2;
              formatter = [ { external.command = "nixfmt"; } ];
            };
          };
        }
        (lib.mkIf cfg.enableNushellIntegration {
          terminal.shell.program = "nu";
        })
      ];
    };

    home.shellAliases = {
      zed = "zeditor";
    };
  };
}
