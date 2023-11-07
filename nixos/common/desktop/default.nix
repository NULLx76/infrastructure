{ pkgs, lib, inputs, ... }: {
  # Bootloader.
  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = lib.mkDefault true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
    };
    kernel.sysctl = { "fs.inotify.max_user_watches" = 524288; };
    initrd = {
      systemd.enable = true;
      verbose = false;
    };
  };

  hardware.keyboard.qmk.enable = true;
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.victor = import ./home.nix;
    extraSpecialArgs = { inherit inputs; };
  };
  services = {

    # Enable my config for the gnome desktop environment
    v.gnome.enable = true;

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
  };

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

  # Global Packages
  environment = { systemPackages = with pkgs; [ wireguard-tools sbctl ]; };

  # programs.virt-manager = {
  #   enable = true;
  # };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  virtualisation = {
    podman.enable = true;
    libvirtd = {
      enable = true;
      qemu.package = pkgs.qemu_kvm;
    };
  };

  fonts.packages = with pkgs; [
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
  programs = {
    steam = {


      enable = true;
      # Open ports in the firewall for Steam Remote Play
      remotePlay.openFirewall = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [ gamescope mangohud ];
      };
    };


    gamemode.enable = true;

    adb.enable = true;
  };
  networking = {
    # Networking
    networkmanager.enable = true;
    firewall.checkReversePath = false;
    firewall.enable = false;
  };
}
