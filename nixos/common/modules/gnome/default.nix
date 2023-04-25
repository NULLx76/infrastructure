{ config, pkgs, lib, flat_hosts, ... }:
with lib;
let cfg = config.services.v.gnome;

in {
  options.services.v.gnome = { enable = mkEnableOption "v.gnome"; };

  config = mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.excludePackages = [ pkgs.xterm ];

    home-manager.sharedModules = [
      ./dconf.nix
    ];

    # Configure keymap in X11
    services.xserver = {
      layout = "us";
      xkbVariant = "altgr-intl";
    };

    # Enable the GNOME Desktop Environment.
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
    environment.gnome.excludePackages =
      (with pkgs; [ gnome-photos gnome-tour gnome-connections ])
      ++ (with pkgs.gnome; [
        atomix # puzzle game
        epiphany # web browser
        geary # email reader
        gedit # text editor
        gnome-calendar
        gnome-clocks
        gnome-contacts
        gnome-maps
        gnome-music
        gnome-notes
        gnome-terminal
        gnome-weather
        hitori # sudoku game
        iagno # go game
        simple-scan # document scanner
        tali # poker game
        totem # video player
      ]);

    # Services required for gnome
    programs.dconf.enable = true;
    services.dbus.enable = true;
    services.udisks2.enable = true;

    # Extra gnome packages
    environment.systemPackages = with pkgs; [
      gnome.gnome-tweaks
      gnome.gnome-boxes
    ];
  };
}
