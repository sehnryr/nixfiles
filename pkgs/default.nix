{ pkgs }:
{
  discord = (pkgs.callPackage ./discord { }).discord;
  graalvm21-ce = pkgs.callPackage ./graalvm-ce { };
}
