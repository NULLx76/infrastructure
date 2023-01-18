{ pkgs, ... }: {
  hardware.enableAllFirmware = true;

  hardware.bluetooth.enable = true;

  services.hardware.bolt.enable = true;

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
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
}
