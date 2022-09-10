{ config, pkgs, ... }:
{
  system.stateVersion = "21.05";
  networking.interfaces.eth0.useDHCP = true;

  services.jackett = {
    enable = true;
    dataDir = "/var/lib/jackett/";
    openFirewall = true;
  };
}
