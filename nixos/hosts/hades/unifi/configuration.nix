{ pkgs, lib, ... }: {
  system.stateVersion = "21.05";
  networking.interfaces.eth0.useDHCP = true;

  environment.systemPackages = [ pkgs.mongodb-4_2 ];

  services.unifi = {
    enable = true;
    unifiPackage = pkgs.unifi;
    mongodbPackage = pkgs.mongodb-4_2;
    openFirewall = true;
  };

  # Required for Java
  # gets forced to true due the lxc profile
  environment.noXlibs = lib.mkForce false;

  # Unifi Web Port
  networking.firewall.allowedTCPPorts = [ 8443 ];
}
