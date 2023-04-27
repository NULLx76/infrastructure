{ pkgs, config, ... }: {
  hardware.enableAllFirmware = true;

  hardware.bluetooth.enable = true;

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

  services.udev.packages = with pkgs; [ wooting-udev-rules ];

  # SSD Trim
  services.fstrim.enable = true;
}
