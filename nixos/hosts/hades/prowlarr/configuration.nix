{ config, pkgs, ... }:
{
  networking.interfaces.eth0.useDHCP = true;
  system.stateVersion = "22.11";

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };
  
  virtualisation.podman.enable = true;

  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      flaresolverr = {
        image = "0x76/flaresolverr:3.0.0.beta2-fixup";
        ports = [
          "8191:8191"
        ];
      };
    };
  };
}
