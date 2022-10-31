{ config, pkgs, ... }:
{
  system.stateVersion = "22.11";
  networking.interfaces.eth0.useDHCP = true;

  fileSystems."/mnt/storage" = {
    device = "storage:/mnt/storage";
    fsType = "nfs";
  };

  services.bazarr = {
    enable = true;
    openFirewall = true;
  };
}
