{ pkgs, ... }: {
  dconf.settings."org/gnome/desktop/peripherals/mouse" = {
    accel-profile = "flat";
  };

  home.packages = with pkgs; [
    zoom-us
  ];
}
