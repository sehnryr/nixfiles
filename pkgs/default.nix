{ pkgs }:
{
  discord = pkgs.callPackage ./discord { };
  graalvm21-ce = pkgs.callPackage ./graalvm21-ce { };
}
