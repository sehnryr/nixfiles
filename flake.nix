{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
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
      nixos-hardware,
      home-manager,
      nur,
      nixgl,
      agenix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (import ./overlays/toml-generator.nix)
          nur.overlay
          nixgl.overlay
        ];
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
    in
    {
      # nixos-rebuild switch --flake .#<hostname>
      nixosConfigurations = {
        "laptop" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit user;
            inherit fonts;
          };

          modules = [
            ./nixos/laptop
            ./nixos/modules
            nixos-hardware.nixosModules.framework-12th-gen-intel
          ];
        };
        "clever-cloud" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit user;
            inherit fonts;
          };

          modules = [
            ./nixos/clever-cloud
            ./nixos/modules
            nixos-hardware.nixosModules.lenovo-thinkpad-t480s
          ];
        };
      };
      # nix run home-manager/release-25.05 -- switch --flake .#<hostname>
      # home-manager switch --flake .#<hostname>
      homeConfigurations = {
        "${user.name}@laptop" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit inputs;
            inherit user;
            inherit ssh;
            inherit fonts;
          };

          modules = [
            ./home-manager/laptop.nix
            ./home-manager/modules
            agenix.homeManagerModules.default
          ];
        };
        "${user.name}@clever-cloud" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit inputs;
            inherit user;
            inherit ssh;
            inherit fonts;
          };

          modules = [
            ./home-manager/clever-cloud.nix
            ./home-manager/modules
            agenix.homeManagerModules.default
          ];
        };
        "${user.name}@desktop" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit inputs;
            inherit nixgl;
            inherit user;
            inherit ssh;
            inherit fonts;
          };

          modules = [
            ./home-manager/desktop.nix
            ./home-manager/modules
            agenix.homeManagerModules.default
          ];
        };
      };
    };
}
