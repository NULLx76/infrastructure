{ ... }: {
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  virtualisation.oci-containers.containers.flaresolverr = {
    image = "flaresolverr/flaresolverr:v3.1.2";
    ports = [ "8191:8191" ];
  };
}
