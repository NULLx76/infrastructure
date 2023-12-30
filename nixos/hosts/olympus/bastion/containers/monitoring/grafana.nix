{ config, pkgs, ... }: {
  services.grafana = {
    enable = true;
    domain = "grafana.olympus";
    port = 80;
    addr = "0.0.0.0";
  };

  networking.firewall.allowedTCPPorts = [ config.services.grafana.port ];
}
