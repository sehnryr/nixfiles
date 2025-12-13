{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.dev;

  moduleNames = builtins.attrNames (builtins.readDir ./.);
  modules = builtins.map (name: ./. + ("/" + name)) moduleNames;
  filterOut = module: modules: builtins.filter (module': module' != module) modules;
in
{
  imports = filterOut ./default.nix modules;

  options.modules.dev = {
    enable = lib.mkEnableOption "dev";
  };

  config = lib.mkIf cfg.enable {
    home.file = {
      ".ssh/master.pub" = {
        text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFPO/hKBeNBJVbq8yPL13KRBLCn+gpXyNtAs1UyvyP9Z";
      };

      ".ssh/clever-cloud.pub" = {
        text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID1krg5H1ekYVacZPCKvYARdBy4JT5M+fGo2EFvJD0n4";
      };
    };

    home.packages = with pkgs; [
      tealdeer
    ];

    programs = {
      codex.enable = true;
      direnv.enable = true;
      neovim.enable = true;
      git.enable = true;
      jujutsu.enable = true;
      zed-editor.enable = true;
    };
  };
}
