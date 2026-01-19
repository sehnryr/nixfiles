{ pkgs }:
{
  discord = pkgs.callPackage ./discord { };
  graalvm21-ce = pkgs.callPackage ./graalvm21-ce { };
  graalvm25-ce = pkgs.callPackage ./graalvm25-ce { };
}
