{
  fetchurl,
  graalvmPackages,
}:
graalvmPackages.buildGraalvm rec {
  version = "25.0.1";

  src = fetchurl {
    url = "https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-${version}/graalvm-community-jdk-${version}_linux-x64_bin.tar.gz";
    hash = "sha256-AeOf4ah/KLhCo+Tjt3vptUTco6WPpuk7kkphBsi6x/s=";
  };

  meta = {
    platforms = [ "x86_64-linux" ];
  };
}
