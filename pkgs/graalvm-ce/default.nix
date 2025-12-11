{
  stdenv,
  fetchurl,
  graalvmPackages,
}:

let
  version = (import ./hashes.nix).version;
  hashes = (import ./hashes.nix).hashes;
in
graalvmPackages.buildGraalvm {
  inherit version;
  src = fetchurl hashes.${stdenv.system};
  meta.platforms = builtins.attrNames hashes;
}
