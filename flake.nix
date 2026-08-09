{
  inputs = {
    systems = {
      url = "path:./systems.nix";
      flake = false;
    };
    utils = {
      url = "path:./utils";
      inputs.systems.follows = "systems";
    };

    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=master";

    nixos-hardware = {
      url = "github:nixos/nixos-hardware?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager?ref=release-26.05";
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
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        systems.follows = "systems";
        darwin.follows = "";
      };
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    betterfox = {
      url = "github:yokoffing/Betterfox";
      flake = false;
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "utils";
      };
    };

    minecraft-server-manager = {
      url = "github:ymelois/minecraft-server-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    moerae = {
      url = "github:ymelois/moerae?rev=a0af4d075146377887448deb977cea6b200280d0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      config = {
        allowUnfree = true;
      };
      overlays = [
        inputs.nur.overlays.default
        inputs.claude-code.overlays.default
        inputs.minecraft-server-manager.overlays.default
        inputs.moerae.overlays.default
        (final: prev: {
          unstable = import inputs.nixpkgs-unstable {
            inherit system;
            inherit config;
          };
        })
        (final: prev: import ./pkgs { pkgs = final; })
      ];

      pkgs = import nixpkgs {
        inherit system;
        inherit config;
        inherit overlays;
      };

      user = {
        name = "youn";
        family = "melois";
        fullName = "Youn Mélois";
        email = "youn@melois.dev";
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
        module:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit user;
            inherit fonts;
          };

          modules = [
            {
              nixpkgs = {
                inherit config;
                inherit overlays;
              };
            }
            ./nixos/modules
            inputs.disko.nixosModules.disko
            inputs.agenix.nixosModules.default
            inputs.minecraft-server-manager.nixosModules.default
            module
          ];
        };

      mkHomeManagerConfiguration =
        module:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit inputs;
            inherit user;
            inherit fonts;
          };

          modules = [
            ./home-manager/modules
            inputs.agenix.homeManagerModules.default
            module
          ];
        };
    in
    {
      # nixos-rebuild switch --flake .#<hostname>
      nixosConfigurations = {
        "desktop" = mkNixosSystem ./nixos/host/desktop;
        "laptop" = mkNixosSystem ./nixos/host/laptop;
        # nixos-rebuild --target-host root@<hostname> switch --flake ~/nixfiles#server
        "server" = mkNixosSystem ./nixos/server;
        "clever-cloud" = mkNixosSystem ./nixos/host/clever-cloud;
      };
      # nix run home-manager/release-26.05 -- switch --flake .#<hostname>
      # home-manager switch --flake .#<hostname>
      homeConfigurations = {
        "desktop" = mkHomeManagerConfiguration ./home-manager/desktop.nix;
        "laptop" = mkHomeManagerConfiguration ./home-manager/laptop.nix;
        "clever-cloud" = mkHomeManagerConfiguration ./home-manager/clever-cloud.nix;
      };
    };
}
