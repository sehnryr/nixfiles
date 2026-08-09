{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.age;
in
{
  options.modules.age.enable = lib.mkEnableOption "Age";

  config = lib.mkIf cfg.enable {
    age = {
      identityPaths = [ "/etc/age/key.txt" ];
      secrets = {
        context7Key.file = ../../../secrets/context7-key.age;
      };
    };
  };
}
