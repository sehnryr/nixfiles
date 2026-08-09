{
  inputs.systems = {
    url = "path:../systems.nix";
    flake = false;
  };

  outputs = { systems, ... }: {
    lib = import ./lib.nix {
      defaultSystems = import systems;
    };
  };
}
