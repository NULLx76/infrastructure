{ lib, stdenvNoCC, fetchurl }: stdenvNoCC.mkDerivation {
  pname = "gitea-agatheme";
  version = "1.2";

  src = fetchurl {
    url = "https://git.lain.faith/attachments/290e2304-92a3-4991-8703-fbbf52f31340";
    sha256 = "424f4e232c7d759485cdf1bcde9edde50f2992cf6bde61c21f71eae03a905543";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    cp $src $out
  '';
}
