{
  config,
  pkgs,
  lib,
  user,
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
      package = pkgs.unstable.zed-editor;
      installRemoteServer = true;
      extraPackages = with pkgs; [
        nil
        nixd
        nixfmt-rfc-style
      ];
    };

    home.shellAliases = {
      zed = "zeditor";
    };

    xdg.configFile."zed/settings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink "${user.configDirectory}/zed/settings.json";
    };
  };
}
