_: {
  programs.home-manager.enable = true;

  home.username = "victor";
  home.homeDirectory = "/home/victor";
  home.stateVersion = "23.05";

  imports = [ ../../../../common/desktop/home.nix ];

  dconf.settings."org/gnome/desktop/peripherals/mouse" = {
    accel-profile = "flat";
  };
}
