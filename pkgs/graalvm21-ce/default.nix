{
  fetchurl,
  graalvmPackages,
}:
graalvmPackages.buildGraalvm rec {
  version = "21.0.2";

  src = fetchurl {
    url = "https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-${version}/graalvm-community-jdk-${version}_linux-x64_bin.tar.gz";
    hash = "sha256-sEgGmqo6mbhPW5V7FizBgaMqQzDLw1QCdmNjxb52rkg=";
  };

  meta = {
    platforms = [ "x86_64-linux" ];
  };
}
