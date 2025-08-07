{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.prism-launcher;
in
{
  options.programs.prism-launcher = {
    enable = lib.mkEnableOption "enable prism-launcher";
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
          graalvm21-ce
          jdk17
          jdk8
        ];
      })
    ];
  };
}
