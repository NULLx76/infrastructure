{ lib, stdenvNoCC, fetchFromGitHub }: stdenvNoCC.mkDerivation rec {
  pname = "dnd-5e-latex-character-sheet-template";
  version = "0.1.0";
  tlType = "run";

  src = fetchFromGitHub {
    owner = "matsavage";
    repo = "DND-5e-LaTeX-Character-Sheet-Template";
    rev = "d9ab382c7c9da4680a99355cb99510a318f159e3";
    sha256 = lib.fakeSha256;
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
    description = "DnD 5e latex character template";
  };
}
