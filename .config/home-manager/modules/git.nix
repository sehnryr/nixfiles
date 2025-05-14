{
  config,
  lib,
  ...
}:

{
  options.modules.git = {
    enable = lib.mkEnableOption "Git configuration";
    userName = lib.mkOption {
      type = lib.types.str;
      description = "Git user name";
    };
    userEmail = lib.mkOption {
      type = lib.types.str;
      description = "Git user email";
    };
    signingKey = lib.mkOption {
      type = lib.types.str;
      description = "SSH public key for signing";
      default = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
    };
  };

  config = lib.mkIf config.modules.git.enable {
    programs.git = {
      enable = true;
      userName = config.modules.git.userName;
      userEmail = config.modules.git.userEmail;
      signing = {
        format = "ssh";
        key = config.modules.git.signingKey;
        signByDefault = true;
      };
      extraConfig = {
        init.defaultBranch = "main";
      };
    };
  };
}
