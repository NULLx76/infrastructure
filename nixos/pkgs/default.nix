# nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
_final: prev: {
  v = {
    glitch-soc = prev.callPackage ./glitch-soc { };

    weave-gitops = prev.callPackage ./weave-gitops { };

    unbound = prev.unbound.override {
      withSystemd = true;
      withDoH = true;
      withDNSCrypt = true;
      withTFO = true;
    };

    dnd-5e-latex-template = prev.callPackage ./dnd-5e-latex-template { };

    gitea-agatheme = prev.callPackage ./gitea-agatheme { };

    # nix-shell -p "(vscode-with-extensions.override {vscodeExtensions = with vscode-extensions; [ jnoortheen.nix-ide ]; })" -I nixpkgs=.
    vscode-extensions = {
      platformio.platformio-ide =
        prev.callPackage ./vscode-extensions/platformio.nix { };
    };

  };

  plex-plexpass = prev.callPackage ./plex-pass { };
  plexRaw-plexpass = prev.callPackage ./plex-pass/raw.nix { };
}
