{
  config,
  pkgs,
  lib,
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
      installRemoteServer = true;
      extraPackages = with pkgs; [
        nixd
        nixfmt
      ];
    };

    home.shellAliases = {
      zed = "zeditor";
    };

    xdg.configFile."zed/settings.json" = {
      source = config.lib.file.mkRelativeOutOfStoreSymlink ./settings.json;
    };

    xdg.configFile."tombi/config.toml" = {
      source = config.lib.file.mkRelativeOutOfStoreSymlink ./config.json;
    };

    programs.git.ignores = lib.mkIf config.programs.git.enable [
      ".zed"
    ];
  };
}
