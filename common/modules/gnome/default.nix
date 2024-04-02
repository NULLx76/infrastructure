{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.v.gnome;
in
{
  options.services.v.gnome = {
    enable = mkEnableOption "v.gnome";
    hm = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable home manager integration to set default dconf values
      '';
    };

    auto-unlock-keyring = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to automatically unlock the keyring upon login.
        This is mostly useful if you are logging in using a fingerprint
        or FIDO device and the keyring does not automatically get unlocked.
        Make sure you have enrolled you password into the keyring unlocker.
      '';
    };
  };

  config = mkIf cfg.enable {
    services = {
      xserver = {
        enable = true;
        excludePackages = [ pkgs.xterm ];
        # Configure keymap in X11
        xkb = {
          layout = "us";
          variant = "altgr-intl";
        };

        # Enable the GNOME Desktop Environment.
        displayManager.gdm.enable = lib.mkDefault true;
        desktopManager.gnome.enable = true;
      };
      udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
      dbus.enable = true;
      udisks2.enable = true;
    };

    services.gnome-autounlock-keyring.enable = cfg.auto-unlock-keyring;

    # Add Home-manager dconf stuff
    home-manager.sharedModules = mkIf cfg.hm [ ./hm.nix ];
    environment.gnome.excludePackages =
      (with pkgs; [
        gnome-photos
        gnome-tour
        gnome-connections
      ])
      ++ (with pkgs.gnome; [
        atomix # puzzle game
        epiphany # web browser
        geary # email reader
        pkgs.gedit # text editor
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

    # Extra gnome packages
    environment.systemPackages = with pkgs; [
      gnome.gnome-tweaks
      gnome.gnome-boxes
    ];
  };
}
