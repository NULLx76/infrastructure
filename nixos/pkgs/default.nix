final: prev: {
  hedgedoc = prev.hedgedoc.overrideAttrs (old: {
    # see https://github.com/NixOS/nixpkgs/issues/176127#issuecomment-1146782555
    preBuild = ''
      export HOME=$TMPDIR
    '';
  });

  vmagent = prev.callPackage ./vmagent { };

  v = {
    unbound = prev.unbound.override {
      withSystemd = true;
      withDoH = true;
      withDNSCrypt = true;
      withTFO = true;
    };

    gitea-agatheme = prev.callPackage ./gitea-agatheme { };
  };
}
