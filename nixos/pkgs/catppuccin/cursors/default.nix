{ stdenv, lib, fetchFromGitHub, xorg, inkscape }:

stdenv.mkDerivation rec {
  pname = "catppuccin-cursors";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "cursors";
    rev = "3d3023606939471c45cff7b643bffc5d5d4ff29c";
    sha256 = "sha256-0wb84q1VtD1myIRxrfQMn9n6w1gFzMA1rHkPqXuXLP0=";
  };

  nativeBuildInputs = [
    xorg.xcursorgen
    inkscape
  ];

  installPhase = ''
    PREFIX="/" DESTDIR=$out make install
  '';

  meta = with lib; {
    description = "Soothing pastel mouse cursors";
    homepage = "https://github.com/catppuccin/cursors";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}