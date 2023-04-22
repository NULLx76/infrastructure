{ pkgs, ... }: {
  hardware.enableAllFirmware = true;

  hardware.bluetooth.enable = true;

  services.hardware.bolt.enable = true;

  # Vulkan
  # hardware.opengl.driSupport = true;
  # hardware.opengl.extraPackages = with pkgs; [
  #   amdvlk
  #   rocm-opencl-icd
  #   rocm-opencl-runtime
  # ];
  # systemd.tmpfiles.rules =
  #   [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}" ];

  # SSD Trim
  services.fstrim.enable = true;
}
