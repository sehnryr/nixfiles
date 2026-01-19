{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.prismlauncher;
in
{
  options.programs.prismlauncher = {
    enable = lib.mkEnableOption "prismlauncher";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (prismlauncher.override {
        additionalPrograms = [
          ffmpeg
          vlc
          alsa-oss
        ];

        jdks = [
          graalvm25-ce
          graalvm21-ce
          jdk17
          jdk8
        ];
      })
    ];
  };
}
