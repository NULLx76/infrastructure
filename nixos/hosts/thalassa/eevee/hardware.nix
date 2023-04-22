{ pkgs, ... }: {
  hardware.enableAllFirmware = true;

  hardware.bluetooth.enable = true;

  services.hardware.bolt.enable = true;

  hardware.opengl.enable = true;

  services.udev.packages = with pkgs; [ wooting-udev-rules ];

  # SSD Trim
  services.fstrim.enable = true;
}
