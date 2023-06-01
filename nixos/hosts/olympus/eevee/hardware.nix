{ pkgs, config, ... }: {
  hardware.enableAllFirmware = true;

  services.hardware.bolt.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.beta;

    # Open drivers cause gdm to crash
    # open = true;

    # nvidia-drm.modeset=1
    modesetting.enable = true;
  };

  # Hardware acceleration
  hardware.opengl = {
    enable = true;

    # Vulkan
    driSupport = true;
  };

  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  # udev
  services.udev.packages = with pkgs; [
    android-udev-rules
    logitech-udev-rules
    wooting-udev-rules
  ];

  # FS
  fileSystems."/".options = [ "compress=zstd" ];

  # SSD Trim
  services.fstrim.enable = true;
}
