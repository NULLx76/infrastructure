{ pkgs, stdenv, electron_14, mkYarnPackage, fetchFromGitLab, lib }:
let electron = electron_14;
in mkYarnPackage rec {
  pname = "deemix-gui";
  version = "0.1.0";

  src = fetchFromGitLab {
    owner = "RemixDev";
    repo = "deemix-gui";
    rev = "06305de9cf65639620eeaee408f1c64cb8610387";
    sha256 = "sha256-498ivYIFUWDamtI38PUEag9ydWpXfhtzgI3rTOcmTJQ=";
  };

  packageJSON = ./package.json;
  yarnLock = ./yarn.lock;

  buildInputs = [ electron ];

  installPhase = ''
    ls -al
    runHook preInstall
    mkdir -p $out/{bin,libexec/${pname}}
    mv node_modules $out/libexec/${pname}/node_modules
    mv deps $out/libexec/${pname}/deps
    runHook postInstall
  '';

  distPhase = ''
    true
  '';

  # distPhase = ''
  #   cd $out
  #   unlink "$out/libexec/${pname}/deps/${pname}/node_modules"
  #   ln -s "$out/libexec/${pname}/node_modules" "$out/libexec/${pname}/deps/${pname}/desktop/node_modules"
  #   ls -al
  #   ls -al libexec
  #   mkdir -p bin
  #   cd bin
  #   echo '#!/bin/sh' > ${pname}
  #   echo "cd $out/libexec/${pname}/deps/${pname}" >> ${pname}
  #   echo "${electron}/bin/electron $out/libexec/${pname}/deps/${pname}/desktop" >> ${pname}
  #   chmod 0755 $out/bin/${pname}
  #   true
  # '';
}
