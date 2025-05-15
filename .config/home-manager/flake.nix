{
  description = "Home Manager configuration of youn";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL/3865170cbc23b32ec7cc8df1ec811fd44b6c2a58";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixgl,
      ...
    }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [
          nixgl.overlay
        ];
      };
    in
    {
      homeConfigurations."youn" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home.nix
          ./fonts
          ./programs
          ./services
        ];

        extraSpecialArgs = {
          nixgl = nixgl;
        };
      };
    };
}
