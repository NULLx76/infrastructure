{ lib, stdenvNoCC, fetchFromGitHub }: stdenvNoCC.mkDerivation rec {
  pname = "dnd-5e-latex-template";
  version = "0.8.0";
  tlType = "run";

  src = fetchFromGitHub {
    owner = "rpgtex";
    repo = "DND-5e-LaTeX-Template";
    rev = "d611f61d2d0f54e621641cffe87b49ca216ccf1a";
    sha256 = "sha256-jSYC0iduKGoUaYI1jrH0cakC45AMug9UodERqsvwVxw=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
      runHook preInstall

      path="$out/tex/latex/${pname}"
      mkdir -p "$path"
      cp -r $src/* $path

      runHook postInstall
  '';

  meta = {
    description = "DnD 5e latex template";
  };
}
