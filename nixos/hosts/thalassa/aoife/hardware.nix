{ pkgs, ... }: {
  hardware.enableAllFirmware = true;

  hardware.bluetooth.enable = true;

  services.hardware.bolt.enable = true;

  # FS
  fileSystems."/".options = [ "compress=zstd" ];

  # Video Driver
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.xserver = {
    dpi = 280;
    xkbOptions = "caps:swapescape";
  };

  # Vulkan
  hardware.opengl.driSupport = true;
  hardware.opengl.extraPackages = with pkgs; [
    amdvlk
    rocm-opencl-icd
    rocm-opencl-runtime
  ];

  systemd.tmpfiles.rules =
    [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}" ];

  # SSD Trim
  services.fstrim.enable = true;

  # Power Management
  services.upower.enable = true;
  services.thermald.enable = true;

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
}
