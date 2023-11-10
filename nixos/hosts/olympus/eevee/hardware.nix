{ pkgs, config, ... }: {
  hardware = {
    enableAllFirmware = true;
    nvidia = {
      # package = config.boot.kernelPackages.nvidiaPackages.stable;

      # Open drivers cause gdm to crash
      # open = true;

      # nvidia-drm.modeset=1
      modesetting.enable = true;
      powerManagement.enable = false;
    };

    # Hardware acceleration
    opengl = {
      enable = true;

      # Vulkan
      driSupport = true;
      driSupport32Bit = true;
    };

    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
  };
  services = {

    hardware.bolt.enable = true;

    xserver.videoDrivers = [ "nvidia" ];

    # udev
    udev.packages = with pkgs; [
      android-udev-rules
      logitech-udev-rules
      wooting-udev-rules
    ];

    # SSD Trim
    fstrim.enable = true;
  };

  # FS
  fileSystems."/".options = [ "compress=zstd" ];
}
