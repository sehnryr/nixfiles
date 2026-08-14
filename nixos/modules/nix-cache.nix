{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.nix-cache;

  bucket = "nix-cache";
  endpoint = "cellar-c2.services.clever-cloud.com";

  cacheUrl = "s3://${bucket}?endpoint=${endpoint}&region=us-east-1&compression=zstd";

  uploader = pkgs.writeShellScript "upload-to-cache" ''
    set -eu
    set -f
    export IFS=' '
    ${pkgs.coreutils}/bin/timeout 300 \
        ${config.nix.package}/bin/nix copy --to "${cacheUrl}" $OUT_PATHS \
        || echo "warning: failed to push to binary cache" >&2
    exit 0
  '';
in
{
  options.modules.nix-cache.enable = lib.mkEnableOption "nix-cache";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.modules.age.enable;
        message = "modules.age is required for nix-cache";
      }
    ];

    age.secrets.nix-cache-key.file = ../../secrets/nix-cache-key.age;
    age.secrets.nix-cache-s3-env.file = ../../secrets/nix-cache-s3-env.age;

    nix.settings = {
      secret-key-files = [ config.age.secrets.nix-cache-key.path ];
      post-build-hook = "${uploader}";

      substituters = [
        "https://cache.nixos.org"
        cacheUrl
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-cache:pCcfH/mDrfqY2V+nhAyGNBrS7+YrGXwtGiYBWAd89zY="
      ];
    };

    systemd.services.nix-daemon = {
      serviceConfig.EnvironmentFile = config.age.secrets.nix-cache-s3-env.path;
      restartTriggers = [ config.age.secrets.nix-cache-s3-env.file ];
    };
  };
}
