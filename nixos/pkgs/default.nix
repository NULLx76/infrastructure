final: prev: {
  hedgedoc = prev.hedgedoc.overrideAttrs (old: {
    # see https://github.com/NixOS/nixpkgs/issues/176127#issuecomment-1146782555
    preBuild = ''
      export HOME=$TMPDIR
    '';
  });

  discord = prev.discord.override { withOpenASAR = true; };

  catppuccin.cursors = prev.callPackage ./catppuccin/cursors { };

  unbound = prev.unbound.override {
    withSystemd = true;
    withDoH = true;
    withDNSCrypt = true;
    withTFO = true;
  };

  v = {
    glitch-soc = prev.callPackage ./glitch-soc { };


    vmagent = prev.callPackage ./vmagent { };
    gitea-agatheme = prev.callPackage ./gitea-agatheme { };
  };
}
