{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-graalvm-21.url = "github:nixos/nixpkgs/ed4db9c6c75079ff3570a9e3eb6806c8f692dc26";

    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    betterfox = {
      url = "github:yokoffing/Betterfox";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-graalvm-21,
      nixos-hardware,
      home-manager,
      disko,
      nur,
      agenix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      config = {
        allowUnfree = true;
      };
      overlays = [
        (final: prev: {
          unstable = import inputs.nixpkgs-unstable {
            inherit system;
            inherit config;
          };
        })
        nur.overlays.default
      ];

      pkgs = import nixpkgs {
        inherit system;
        inherit config;
        inherit overlays;
      };
      pkgs-graalvm-21 = import nixpkgs-graalvm-21 {
        inherit system;
      };

      user = rec {
        name = "youn";
        email = "youn@melois.dev";
        homeDirectory = "/home/${name}";
        nixConfigDirectory = "${homeDirectory}/nixfiles";
        homeManagerConfigDirectory = "${nixConfigDirectory}/home-manager";
        nixosConfigDirectory = "${nixConfigDirectory}/nixos";
      };

      ssh = {
        private.path = "${user.homeDirectory}/.ssh/master";
        public.text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFPO/hKBeNBJVbq8yPL13KRBLCn+gpXyNtAs1UyvyP9Z";
      };

      fonts = {
        sans = {
          default = {
            package = pkgs.cantarell-fonts;
            family = "Cantarell";
          };
          noto-cjk-sans = {
            package = pkgs.noto-fonts-cjk-sans;
            family = "Noto Sans CJK";
          };
        };
        serif = {
          default = {
            package = pkgs.dejavu_fonts;
            family = "DejaVu Serif";
          };
          noto-cjk-serif = {
            package = pkgs.noto-fonts-cjk-serif;
            family = "Noto Serif CJK";
          };
        };
        monospace = {
          default = {
            package = pkgs.maple-mono.NL-NF;
            family = "Maple Mono NL NF";
          };
        };
        emoji = {
          default = {
            package = pkgs.noto-fonts-color-emoji;
            family = "Noto Color Emoji";
          };
        };
      };

      mkNixosSystem =
        modules:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit user;
            inherit ssh;
            inherit fonts;
          };

          modules = [ ./nixos/modules ] ++ modules;
        };

      mkHomeManagerConfiguration =
        modules:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit pkgs-graalvm-21;
            inherit inputs;
            inherit user;
            inherit ssh;
            inherit fonts;
          };

          modules = [
            ./home-manager/common.nix
            ./home-manager/modules
            agenix.homeManagerModules.default
          ]
          ++ modules;
        };
    in
    {
      # nixos-rebuild switch --flake .#<hostname>
      nixosConfigurations = {
        "desktop" = mkNixosSystem [
          ./nixos/desktop
        ];
        "laptop" = mkNixosSystem [
          ./nixos/laptop
          nixos-hardware.nixosModules.framework-12th-gen-intel
        ];
        # nixos-rebuild --target-host root@<hostname> switch --flake ~/nixfiles#server
        "server" = mkNixosSystem [
          disko.nixosModules.disko
          ./nixos/server
        ];
        "clever-cloud" = mkNixosSystem [
          ./nixos/clever-cloud
          nixos-hardware.nixosModules.lenovo-thinkpad-t480s
        ];
      };
      # nix run home-manager/release-25.05 -- switch --flake .#<hostname>
      # home-manager switch --flake .#<hostname>
      homeConfigurations = {
        "${user.name}@desktop" = mkHomeManagerConfiguration [
          ./home-manager/desktop.nix
        ];
        "${user.name}@laptop" = mkHomeManagerConfiguration [
          ./home-manager/laptop.nix
        ];
        "${user.name}@clever-cloud" = mkHomeManagerConfiguration [
          ./home-manager/clever-cloud.nix
        ];
      };
    };
}
