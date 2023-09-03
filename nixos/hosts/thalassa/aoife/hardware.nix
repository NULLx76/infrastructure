{ pkgs, ... }: {
  hardware.enableAllFirmware = true;

  hardware.bluetooth.enable = true;

  services.hardware.bolt.enable = true;

  services.fprintd.enable = true;

  # hardware.trackpoint.enable = true;

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

  # tpm
  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true;  # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  security.tpm2.tctiEnvironment.enable = true;  # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  users.users.victor.extraGroups = [ "tss" ];  # tss group has access to TPM devices
}
