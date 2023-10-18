{ pkgs, ... }: {
  hardware = {
    enableAllFirmware = true;

    bluetooth.enable = true;

    # Vulkan
    opengl.driSupport = true;
    opengl.extraPackages = with pkgs; [
      amdvlk
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
  };
  services = {

    hardware.bolt.enable = true;

    fprintd.enable = true;

    # Video Driver
    xserver.videoDrivers = [ "amdgpu" ];
    xserver = {
      dpi = 280;
      xkbOptions = "caps:swapescape";
    };

    # SSD Trim
    fstrim.enable = true;

    # Power Management
    upower.enable = true;
    thermald.enable = true;
  };

  # hardware.trackpoint.enable = true;

  # FS
  fileSystems."/".options = [ "compress=zstd" ];

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
  security = {
    tpm2 = {

      # tpm
      enable = true;
      pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
      tctiEnvironment.enable = true;
    };
  }; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  users.users.victor.extraGroups = [ "tss" ]; # tss group has access to TPM devices
}
