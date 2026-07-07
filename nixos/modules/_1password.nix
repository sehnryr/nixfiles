{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.modules._1password;
in
{
  options.modules._1password.enable = lib.mkEnableOption "1Password";

  config = lib.mkIf cfg.enable {
    programs._1password.enable = true;

    programs._1password-gui = {
      enable = lib.mkDefault true;
      polkitPolicyOwners = lib.mkDefault [ user.name ];
    };

    environment.etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          zen
        '';
        mode = "0755";
      };
    };
  };
}
