final: prev: {
  catppuccin.cursors = prev.callPackage ./catppuccin/cursors { };

  vmagent = prev.callPackage ./vmagent { };

  v = {
    glitch-soc = prev.callPackage ./glitch-soc { };

    unbound = prev.unbound.override {
      withSystemd = true;
      withDoH = true;
      withDNSCrypt = true;
      withTFO = true;
    };

    dnd-5e-latex-template = prev.callPackage ./dnd-5e-latex-template { };
    dnd-5e-latex-character-sheet-template = prev.callPackage ./dnd-5e-latex-character-sheet-template { };

    gitea-agatheme = prev.callPackage ./gitea-agatheme { };
  };
}
