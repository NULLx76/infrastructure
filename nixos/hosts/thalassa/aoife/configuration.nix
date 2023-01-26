# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-z
    ./hardware.nix
    ./networking.nix
    ./desktop-env.nix
  ];

  # Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # kernelPackages = pkgs.linuxKernel.packages.linux_zen; 
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
    };
    kernel.sysctl = { "fs.inotify.max_user_watches" = 524288; };
    initrd = {
      kernelModules = [ "amdgpu" ];
      systemd.enable = true;
      verbose = false;
    };
    resumeDevice = "/dev/nvme0n1p2";
  };

  fileSystems."/".options = [ "compress=zstd" ];

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

  # Enable CUPS to print documents.
  services.printing.enable = true;

  environment.systemPackages = with pkgs; [ wireguard-tools ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.victor = import ./home;
    extraSpecialArgs = { inherit inputs; };
  };

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

  virtualisation = {
    podman.enable = true;
    libvirtd = {
      enable = true;
      qemu.package = pkgs.qemu_kvm;
    };
  };

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

  programs.steam = {
    enable = true;
    # Open ports in the firewall for Steam Remote Play
    remotePlay.openFirewall = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  # Enable ccache
  programs.ccache.enable = true;
  programs.ccache.packageNames = [
    "evolution-data-server"
  ];
  nix.settings.extra-sandbox-paths =
    [ (toString config.programs.ccache.cacheDir) ];
}
