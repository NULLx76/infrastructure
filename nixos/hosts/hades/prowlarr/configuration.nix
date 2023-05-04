_: {
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
        image = "flaresolverr/flaresolverr:v3.1.2";
        ports = [ "8191:8191" ];
      };
    };
  };
}
