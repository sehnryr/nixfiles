{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=master";

    nixos-hardware.url = "github:nixos/nixos-hardware?ref=master";

    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.11";
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

    opnix = {
      url = "github:brizzbuzz/opnix";
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
      disko,
      nur,
      opnix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      config = {
        allowUnfree = true;
      };
      overlays = [
        nur.overlays.default
        (final: prev: {
          unstable = import inputs.nixpkgs-unstable {
            inherit system;
            inherit config;
          };
        })
        (final: pref: import ./pkgs { pkgs = final; })
      ];

      pkgs = import nixpkgs {
        inherit system;
        inherit config;
        inherit overlays;
      };

      user = rec {
        name = "youn";
        family = "melois";
        fullName = "Youn Mélois";
        email = "youn@melois.dev";
        homeDirectory = "/home/${name}";
        nixfilesDirectory = "${homeDirectory}/nixfiles";
        configDirectory = "${nixfilesDirectory}/config";
        homeManagerConfigDirectory = "${nixfilesDirectory}/home-manager";
        nixosConfigDirectory = "${nixfilesDirectory}/nixos";
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
            opnix.nixosModules.default
          ]
          ++ modules;
        };

      mkHomeManagerConfiguration =
        modules:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit inputs;
            inherit user;
            inherit fonts;
          };

          modules = [
            ./home-manager/modules
            opnix.homeManagerModules.default
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
      # nix run home-manager/release-25.11 -- switch --flake .#<hostname>
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
