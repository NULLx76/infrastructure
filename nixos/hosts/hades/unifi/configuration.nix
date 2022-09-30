{ config, pkgs, lib, ... }:
{
  system.stateVersion = "21.05";
  networking.interfaces.eth0.useDHCP = true;

  services.unifi = {
    enable = true;
    jrePackage = pkgs.jre8_headless;
    unifiPackage = pkgs.unifi;
    mongodbPackage = pkgs.mongodb;
    openPorts = true;
  };

  # Required for Java
  # gets forced to true due the lxc profile
  environment.noXlibs = lib.mkForce false;

  # Unifi Web Port
  networking.firewall.allowedTCPPorts = [ 8443 ];
}
