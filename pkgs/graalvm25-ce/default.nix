{
  fetchurl,
  graalvmPackages,
}:
graalvmPackages.buildGraalvm rec {
  version = "25.0.2";

  src = fetchurl {
    url = "https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-${version}/graalvm-community-jdk-${version}_linux-x64_bin.tar.gz";
    hash = "sha256-4L55HI/aTQO2sKDLgk/vMUlzYXAFezpRUlK0RBlgavA=";
  };

  meta = {
    platforms = [ "x86_64-linux" ];
  };
}
