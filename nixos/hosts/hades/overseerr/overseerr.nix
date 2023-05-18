{ ... }: {
  networking.firewall.allowedTCPPorts = [ 5055 ];
  # TODO: Write NixOS package https://github.com/NixOS/nixpkgs/issues/135885
  virtualisation.oci-containers.containers.overseerr = {
    image = "ghcr.io/sct/overseerr:1.32.5";
    environment = { TZ = "Europe/Amsterdam"; };
    ports = [ "5055:5055" ];
    volumes = [ "/var/lib/overseerr/config:/app/config" ];
  };
}
