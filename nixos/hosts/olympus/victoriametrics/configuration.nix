# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  vmPort = 8428;
  vs = config.vault-secrets.secrets;
in
{
  imports = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [ ];

  networking.firewall.allowedTCPPorts = [ vmPort config.services.grafana.port ];
  networking.firewall.allowedUDPPorts = [ vmPort ];

  services.victoriametrics = {
    enable = true;
    listenAddress = ":${toString vmPort}";
    # Data Retention period in months
    retentionPeriod = 12;
  };

  services.vmagent = {
    enable = true;
    openFirewall = true;
    prometheusConfig = {
      global = {
        scrape_interval = "1m";
        scrape_timeout = "30s";
      };
      scrape_configs = [
        {
          job_name = "nginx";
          static_configs = [
            {
              targets = [ "nginx.olympus:9113" ];
              labels.app = "nginx";
            }
          ];
        }
        {
          job_name = "synapse";
          metrics_path = "/_synapse/metrics";
          static_configs = [{
            targets = [ "synapse.olympus:9000" ];
            labels.app = "synapse";
          }];
        }
        {
          job_name = "wireguard";
          static_configs = [{
            targets = [ "wireguard.olympus:9586" ];
            labels.app = "wireguard";
          }];
        }
      ];
    };
  };

  vault-secrets.secrets.grafana = {
    user = "grafana";
    group = "grafana";
  };

  services.grafana = {
    enable = true;
    addr = "0.0.0.0";
    port = 2342;
    domain = "grafana.0x76.dev";
    rootUrl = "https://grafana.0x76.dev";
    security.adminPasswordFile = "${vs.grafana}/password";
  };
}
