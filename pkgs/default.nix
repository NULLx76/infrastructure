# nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
final: prev: {
  v = {
    glitch-soc = prev.callPackage ./glitch-soc { };

    unbound = prev.unbound.override {
      withSystemd = true;
      withDoH = true;
      withDNSCrypt = true;
      withTFO = true;
    };

    dnd-5e-latex-template = prev.callPackage ./dnd-5e-latex-template { };

    roundcube-swipe = prev.callPackage ./roundcube-swipe { };

    gitea-agatheme = prev.callPackage ./gitea-agatheme { };

    # nix-shell -p "(vscode-with-extensions.override {vscodeExtensions = with vscode-extensions; [ jnoortheen.nix-ide ]; })" -I nixpkgs=.
    vscode-extensions = {
      platformio.platformio-ide =
        prev.callPackage ./vscode-extensions/platformio.nix { };
    };

    hyprland-workspaces = prev.callPackage ./hyprland-workspaces { };
  };

  plex-plexpass = prev.callPackage ./plex-pass { };
  plexRaw-plexpass = prev.callPackage ./plex-pass/raw.nix { };
}
