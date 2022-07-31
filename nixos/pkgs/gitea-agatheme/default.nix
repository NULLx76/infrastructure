{ lib, stdenv, fetchurl }: stdenv.mkDerivation rec {
  pname = "gitea-agatheme";
  version = "1.1";

  src = fetchurl {
    url = "https://git.lain.faith/attachments/4c2c2237-1e67-458e-8acd-92a20d382777";
    sha256 = "sha256-uwtg6BAR5J28Ls3naQkJg7xBEfZPXVS5INH+bsVn4Uk=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    cp $src $out
  '';
}
