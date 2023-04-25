{ pkgs, config, ... }: {
  hardware.enableAllFirmware = true;

  services.hardware.bolt.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  services.udev.packages = with pkgs; [ wooting-udev-rules ];


  # FS
  fileSystems."/".options = [ "compress=zstd" ];

  # SSD Trim
  services.fstrim.enable = true;
}
