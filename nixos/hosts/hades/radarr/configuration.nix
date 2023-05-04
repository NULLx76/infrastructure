_: {
  system.stateVersion = "21.05";
  networking.interfaces.eth0.useDHCP = true;

  fileSystems."/mnt/storage" = {
    device = "storage:/mnt/storage";
    fsType = "nfs";
  };

  services.radarr = {
    enable = true;
    dataDir = "/data/radarr";
    openFirewall = true;
  };
}
