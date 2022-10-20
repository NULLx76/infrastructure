# nix-build -E 'with import <nixpkgs> {}; callPackage ./platformio.nix {}'
final: prev: {
  catppuccin.cursors = prev.callPackage ./catppuccin/cursors { };

  v = {
    glitch-soc = prev.callPackage ./glitch-soc { };

    deemix-gui = prev.callPackage ./deemix-gui { };

    unbound = prev.unbound.override {
      withSystemd = true;
      withDoH = true;
      withDNSCrypt = true;
      withTFO = true;
    };

    dnd-5e-latex-template = prev.callPackage ./dnd-5e-latex-template { };

    gitea-agatheme = prev.callPackage ./gitea-agatheme { };

    vscode-extensions = {
      platformio.platformio-ide =
        prev.callPackage ./vscode-extensions/platformio.nix { };
    };
  };
}
