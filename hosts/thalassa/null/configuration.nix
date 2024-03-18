# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, inputs, ... }:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    export LIBVA_DRIVER_NAME=nvidia
    export GBM_BACKEND=nvidia-drm

    exec "$@"
  '';
  run-hyprland = pkgs.writeShellScriptBin "run-hyprland" ''
    export _JAVA_AWT_WM_NONREPARENTING=1
    export XCURSOR_SIZE=32

    export CLUTTER_BACKEND=wayland
    export XDG_SESSION_TYPE=wayland
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
    export MOZ_ENABLE_WAYLAND=1
    export WLR_NO_HARDWARE_CURSORS=1
    export WLR_BACKEND=vulkan
    export QT_QPA_PLATFORM=wayland
    export GDK_BACKEND=wayland
    export SDL_VIDEODRIVER=wayland

    exec Hyprland
  '';
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./rescue-boot.nix
    ./networking.nix
  ];
  home-manager = {

    # home-manager
    useGlobalPkgs = true;
    useUserPackages = true;
    users.vivian = import ./home;
    extraSpecialArgs = { inherit inputs; };
  };

  security = {

    pam.services.swaylock = { };

    sudo.wheelNeedsPassword = true;
    rtkit.enable = true;

    # Enables logging in with my Solokey
    pam.u2f = {
      enable = true;
      debug = false;
      cue = true;
      control = "sufficient";
      authFile =
        "/etc/u2f-mappings"; # use `pamu2fcfg` from `pkgs.pam_u2f` to generate this config
    };
  };

  fonts = {
    fonts = with pkgs; [
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

    enableDefaultFonts = false;

    fontconfig = {
      defaultFonts = {
        monospace = [ "DejaVuSansMono Nerd Font" "Noto Color Emoji" ];
        sansSerif =
          [ "DejaVu Sans" "DejaVuSansMono Nerd Font" "Noto Color Emoji" ];
        serif =
          [ "DejaVu Serif" "DejaVuSansMono Nerd Font" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # Bootloader.
  # boot.initrd.systemd.enable = true; # Experimental
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.editor = false;
      systemd-boot.enable = true;
      # loader.systemd-boot.configurationLimit = 6;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
    };

    kernel.sysctl = { "fs.inotify.max_user_watches" = 524288; };
  };
  services = {

    gnome.gnome-keyring.enable = true;

    udisks2.enable = true;
    dbus.enable = true;

    xserver = {
      enable = false;
      layout = "us";
      xkbVariant = "altgr-intl";
      xkbOptions = "caps:swapescape";
      videoDrivers = [ "nvidia" ];
    };
    blueman.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;
    pipewire = {
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

    fstrim.enable = true;

    # don't shutdown when power button is short-pressed
    logind.extraConfig = ''
      HandlePowerKey=suspend
    '';

    udev.packages = with pkgs; [
      android-udev-rules
      logitech-udev-rules
      wooting-udev-rules
    ];
  };
  fileSystems = {

    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [ "compress=zstd" "noatime" ];
  };
  i18n = {

    # Filesystem dedup
    # services.beesd.filesystems = {
    #  root = {
    #    spec = "LABEL=nixos";
    #    hashTableSizeMB = 256;
    #    verbosity = "crit";
    #    extraOptions = [ "--loadavg-target" "2.0" ];
    #  };
    # };

    # Select internationalisation properties.
    defaultLocale = "en_GB.utf8";

    extraLocaleSettings = {
      LC_ADDRESS = "nl_NL.UTF-8";
      LC_IDENTIFICATION = "nl_NL.UTF-8";
      LC_MEASUREMENT = "nl_NL.UTF-8";
      LC_MONETARY = "nl_NL.UTF-8";
      LC_NAME = "nl_NL.UTF-8";
      LC_NUMERIC = "nl_NL.UTF-8";
      LC_PAPER = "nl_NL.UTF-8";
      LC_TELEPHONE = "nl_NL.UTF-8";
      LC_TIME = "en_DK.UTF-8";
    };

    supportedLocales =
      [ "en_GB.UTF-8/UTF-8" "nl_NL.UTF-8/UTF-8" "en_DK.UTF-8/UTF-8" ];
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
  programs = {

    # Hyprland
    hyprland = {
      enable = true;
      package = null; # Managed by home manager
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    ssh.startAgent = true;
  };

  environment.loginShellInit = ''
    if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
      ${run-hyprland}/bin/run-hyprland
    fi
  '';
  hardware = {

    nvidia.prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };

    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        libvdpau-va-gl
      ];
    };

    bluetooth.enable = true;

    saleae-logic.enable = true;
    pulseaudio.enable = false;
  };

  virtualisation.podman.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;

  environment.systemPackages = with pkgs; [
    pciutils
    nvidia-offload
    run-hyprland
    wireguard-tools
    slurp
    gdb

    swaylock-effects # Has to be installed globally so that pam module works
  ];

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
