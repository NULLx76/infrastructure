_: {
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  virtualisation.oci-containers.containers.flaresolverr = {
    image = "flaresolverr/flaresolverr:v3.3.10";
    ports = [ "8191:8191" ];
  };
}
