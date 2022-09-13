# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:
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
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # home-manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.victor = import ./home;
  home-manager.extraSpecialArgs = {
    inherit inputs;
  };

  security.pam.services.swaylock = { };

  security.sudo.wheelNeedsPassword = true;

  fonts = {
    fonts = with pkgs; [
      material-design-icons
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      dejavu_fonts
      (nerdfonts.override { fonts = [ "DejaVuSansMono" "Ubuntu" "DroidSansMono" "NerdFontsSymbolsOnly" ]; })
    ];

    enableDefaultFonts = false;

    fontconfig = {
      defaultFonts = {
        monospace = [ "DejaVuSansMono Nerd Font" "Noto Color Emoji" ];
        sansSerif = [ "DejaVu Sans" "DejaVuSansMono Nerd Font" "Noto Color Emoji" ];
        serif = [ "DejaVu Serif" "DejaVuSansMono Nerd Font" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 6;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable networking
  networking.networkmanager.enable = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  fileSystems."/".options = [ "compress=zstd" ];
  # Filesystem dedup
  services.beesd.filesystems = {
    root = {
      spec = "LABEL=nixos";
      hashTableSizeMB = 256;
      verbosity = "crit";
      extraOptions = [ "--loadavg-target" "2.0" ];
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.utf8";

  i18n.extraLocaleSettings = {
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

  i18n.supportedLocales = [
    "en_GB.UTF-8/UTF-8"
    "nl_NL.UTF-8/UTF-8"
    "en_DK.UTF-8/UTF-8"
  ];

  xdg = {
    portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [
        # xdg-desktop-portal-gtk
      ];
    };
  };
  services.dbus.enable = true;

  # Hyprland
  programs.hyprland = {
    enable = true;
    package = null; # Managed by home manager
  };

  environment.loginShellInit = ''
    if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
      ${run-hyprland}/bin/run-hyprland
    fi
  '';

  services.xserver = {
    enable = false;
    layout = "us";
    xkbVariant = "altgr-intl";
    xkbOptions = "caps:swapescape";
    videoDrivers = [ "nvidia" ];
  };

  hardware.nvidia = {
    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
    ];
  };

  virtualisation.podman.enable = true;

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
    pciutils
    nvidia-offload
    run-hyprland
    vim
    wireguard-tools
    slurp
    gdb

    swaylock-effects # Has to be installed globally so that pam module works
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  services.fstrim.enable = true;

  # Allow reverse path for wireguard
  networking.firewall = {
    # if packets are still dropped, they will show up in dmesg
    logReversePathDrops = true;
    # wireguard trips rpfilter up
    extraCommands = ''
      ip46tables -t raw -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
      ip46tables -t raw -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
    '';
    extraStopCommands = ''
      ip46tables -t raw -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
      ip46tables -t raw -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
    '';
  };

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  # Enables logging in with my Solokey
  security.pam.u2f = {
    enable = true;
    debug = false;
    cue = true;
    control = "sufficient";
    authFile = "/etc/u2f-mappings"; # use `pamu2fcfg` from `pkgs.pam_u2f` to generate this config
  };

  services.udev.packages = [ pkgs.qmk-udev-rules ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
