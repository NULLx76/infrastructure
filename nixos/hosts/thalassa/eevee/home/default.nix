{ lib, config, pkgs, inputs, ... }:
let
  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full;
    dnd-5e-latex-template = { pkgs = [ pkgs.v.dnd-5e-latex-template ]; };
  };
in {
  programs.home-manager.enable = true;

  home.username = "victor";
  home.homeDirectory = "/home/victor";
  home.stateVersion = "23.05";

  imports = [ ../../../../common/desktop/home.nix ];

  dconf.settings."org/gnome/desktop/peripherals/mouse" = {
    accel-profile = "flat";
  };
}
