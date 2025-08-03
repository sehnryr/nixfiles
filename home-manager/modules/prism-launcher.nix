{
  config,
  pkgs,
  pkgs-graalvm-21,
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
          pkgs-graalvm-21.graalvm-ce
          jdk17
          jdk8
        ];
      })
    ];
  };
}
