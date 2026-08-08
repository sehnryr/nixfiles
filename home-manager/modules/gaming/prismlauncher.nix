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
  config = lib.mkIf cfg.enable {
    programs.prismlauncher = {
      package = pkgs.prismlauncher.override {
        additionalPrograms = with pkgs; [
          ffmpeg
          vlc
          alsa-oss
        ];

        jdks = with pkgs; [
          graalvm25-ce
          graalvm21-ce
          jdk17
          jdk8
        ];
      };
    };
  };
}
