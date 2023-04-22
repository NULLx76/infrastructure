{ pkgs, config, ... }: {
  hardware.enableAllFirmware = true;

  hardware.bluetooth.enable = true;

  services.hardware.bolt.enable = true;

  hardware.opengl.enable = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  services.udev.packages = with pkgs; [ wooting-udev-rules ];

  # SSD Trim
  services.fstrim.enable = true;
}
