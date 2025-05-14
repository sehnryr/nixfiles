{
  config,
  lib,
  ...
}:

{
  options.modules.shell = {
    enable = lib.mkEnableOption "Shell configuration";
    useNushell = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to use Nushell as the default shell";
    };
  };

  config = lib.mkIf config.modules.shell.enable {
    programs.nushell = lib.mkIf config.modules.shell.useNushell {
      enable = true;
      settings = {
        show_banner = false;
        history = {
          file_format = "sqlite";
          max_size = 1000000;
          sync_on_enter = true;
          isolation = true;
        };
        ls.clickable_links = false;
        rm.always_trash = true;
      };
      environmentVariables = {
        SSH_AUTH_SOCK = lib.hm.nushell.mkNushellInline ''$env.XDG_RUNTIME_DIR | path join "ssh-agent.socket"'';
        BINSTALL_NO_CONFIRM = "";
      };
      configFile.text = ''
        use std/util "path add"
        path add "${config.home.homeDirectory}/.cargo/bin"
      '';
    };

    programs.carapace = lib.mkIf config.modules.shell.useNushell {
      enable = true;
      enableNushellIntegration = true;
    };

    programs.starship = {
      enable = true;
      enableNushellIntegration = true;
      settings = {
        scala.detect_folders = [ ];
      };
    };

    programs.direnv = {
      enable = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };

    home.shell.enableNushellIntegration = config.modules.shell.useNushell;
  };
}
