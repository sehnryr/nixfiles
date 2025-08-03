{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.sccache;
in
{
  options.programs.sccache = {
    enable = lib.mkEnableOption "enable sccache";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.sccache
    ];

    home.activation.aws-credentials = lib.hm.dag.entryBetween [ "agenix" ] [ "cleanup" ] ''
      mkdir -p "$HOME/.aws"
      ln -sf "${config.age.secrets."sccache-aws-credentials".path}" "$HOME/.aws/credentials"
    '';

    home.sessionVariables = {
      SCCACHE_BUCKET = "sccache";
      SCCACHE_ENDPOINT = "cellar-c2.services.clever-cloud.com";
      SCCACHE_REGION = "US";

      RUSTC_WRAPPER = "${pkgs.sccache}/bin/sccache";
    };
  };
}
