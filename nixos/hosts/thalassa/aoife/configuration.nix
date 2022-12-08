# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-z
  ];

  # Bootloader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
    };
    kernel.sysctl = { "fs.inotify.max_user_watches" = 524288; };
    initrd.kernelModules = [ "amdgpu" ];
  };

  fileSystems."/".options = [ "compress=zstd" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  hardware.opengl.driSupport = true;
  hardware.opengl.extraPackages = with pkgs; [
    amdvlk
    rocm-opencl-icd
    rocm-opencl-runtime
  ];
  systemd.tmpfiles.rules =
    [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}" ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.xserver.excludePackages = [ pkgs.xterm ];

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

  programs.dconf.enable = true;
  services.udisks2.enable = true;
  services.dbus.enable = true;
  services.fstrim.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "altgr-intl";
    xkbOptions = "caps:swapescape";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
    gnome.gnome-boxes
    wireguard-tools
  ];

  networking.firewall.checkReversePath = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.victor = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.victor = import ./home;
    extraSpecialArgs = { inherit inputs; };
  };

  virtualisation.podman.enable = true;

  fonts.fonts = with pkgs; [
    material-design-icons
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    dejavu_fonts
    (nerdfonts.override {
      fonts =
        [ "DejaVuSansMono" "Ubuntu" "DroidSansMono" "NerdFontsSymbolsOnly" ];
    })
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # networking.firewall.enable = false;

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
