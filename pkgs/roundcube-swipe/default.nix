{ runCommand, fetchFromGitHub }:
let
  roundcubePlugin = { version, src, ... }:

    runCommand "roundcube-plugin-swipe-${version}" { } ''
      mkdir -p $out/plugins/
      cp -r ${src} $out/plugins/swipe
    '';
in
roundcubePlugin rec {
  pname = "roundcube-swipe";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "johndoh";
    repo = pname;
    rev = "de96f82183bc593d879c335e6614fa983d51abfc";
    sha256 = "sha256-vrMSvGwUzufSFDsUvUSL9JLR/+GtWdebVqgKiXMOOq4=";
  };
}
