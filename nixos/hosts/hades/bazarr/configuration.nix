{ config, pkgs, ... }:
{
  system.stateVersion = "21.05";
  networking.interfaces.eth0.useDHCP = true;

  fileSystems."/mnt/storage" = {
    device = "storage:/mnt/storage";
    fsType = "nfs";
  };
}
