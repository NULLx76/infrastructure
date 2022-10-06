{ lib, stdenv, fetchurl, appimageTools, makeWrapper, electron, xorg, pipewire }:

stdenv.mkDerivation rec {
  pname = "deemix-gui";
  version = "2022-08-20";

  src = fetchurl {
    url = "https://download.deemix.app/gui/linux-x64-latest.AppImage";
    sha256 = "sha256-poEvEIYd5FXRweAGIK5AzPjBWY3p8ertiBPbEV0sv+c=";
    name = "${pname}-${version}.AppImage";
  };

  appimageContents = appimageTools.extractType2 {
    name = "${pname}-${version}";
    inherit src;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/${pname} $out/share/applications

    cp -a ${appimageContents}/{locales,resources} $out/share/${pname}
    cp -a ${appimageContents}/usr/share/icons $out/share

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags $out/share/${pname}/resources/app.asar \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [ stdenv.cc.cc xorg.libXtst pipewire ]
      }" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
  '';

  meta = with lib; { platforms = [ "x86_64-linux" ]; };
}
