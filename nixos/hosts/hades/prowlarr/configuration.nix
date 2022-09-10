{ config, pkgs, ... }:
{
  networking.interfaces.eth0.useDHCP = true;
  system.stateVersion = "21.05";

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };
}
