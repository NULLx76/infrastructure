{ runCommand, fetchzip }:
let
  roundcubePlugin = { pname, version, src }:

    runCommand "roundcube-plugin-${pname}-${version}" { } ''
      mkdir -p $out/plugins/
      cp -r ${src} $out/plugins/${pname}
    '';
in roundcubePlugin rec {
  pname = "roundcube-swipe";
  version = "0.5";

  src = fetchzip {
    url =
      "https://github.com/johndoh/roundcube-swipe/archive/refs/tags/${version}.tar.gz";
    sha256 = "sha256-ExTnYE4uF8E+Fatz7fL+vVmxgLxawEI30Rw2uAWNCNw=";
  };
}
