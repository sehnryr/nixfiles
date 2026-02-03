{
  callPackage,
  fetchurl,
  lib,
  discord,
}:
callPackage ./linux.nix rec {
  pname = "discord";
  version = "0.0.123";

  src = fetchurl {
    url = "https://stable.dl2.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
    hash = "sha256-2cNAfYzPbZ9O8s4b3RBLki8aM9TiFuZcGffFbY4zxJQ=";
  };

  branch = "stable";
  binaryName = desktopName;
  desktopName = "Discord";
  self = discord;

  meta = {
    description = "All-in-one cross-platform voice and text chat for gamers";
    downloadPage = "https://discordapp.com/download";
    homepage = "https://discordapp.com/";
    license = lib.licenses.unfree;
    mainProgram = "discord";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
