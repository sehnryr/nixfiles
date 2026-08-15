{
  modulesPath,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./minecraft.nix
    ./syncthing.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    neovim
    gitMinimal
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.systemd.enable = false;

  zramSwap = {
    enable = true;
    memoryPercent = 200;
  };

  networking.hostName = "server";

  modules = {
    headscale = {
      enable = true;
      hostname = "headscale.youn.dev";
      baseDomain = "youn.internal";
    };

    tailscale = {
      enable = true;
      loginServer = "https://headscale.youn.dev";
    };
  };

  age.identityPaths = [ "/etc/age/key.txt" ];
  users.users."root" = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFPO/hKBeNBJVbq8yPL13KRBLCn+gpXyNtAs1UyvyP9Z"
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  networking.firewall = {
    enable = true;
  };

  system.stateVersion = "25.05";
}
