# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, ... }:
let
  vmPort = 8428;
  grafanaDomain = config.meta.exposes.grafana.domain;
  grafanaPort = config.meta.exposes.grafana.port;
  vs = config.vault-secrets.secrets;
in {
  imports = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
  networking.firewall.allowedTCPPorts = [ vmPort grafanaPort ];
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
          job_name = "kea";
          static_configs = [{
            targets = [ "dhcp.olympus:9547" ];
            labels.app = "dhcp";
          }];
        }
        {
          job_name = "nginx";
          static_configs = [{
            targets = [ "nginx.olympus:9113" ];
            labels.app = "nginx";
          }];
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
    settings = {
      server = {
        domain = grafanaDomain;
        root_url = "https://${grafanaDomain}";
        http_addr = "0.0.0.0";
        http_port = grafanaPort;
      };
      security.admin_password = "$__file{${vs.grafana}/password}";

      "auth.generic_oauth" = {
        name = "Dex";
        icon = "signin";
        enabled = true;
        allow_sign_up = true;
        client_id = "grafana";
        client_secret = "$__file{${vs.grafana}/dex_client_secret}";
        scopes = toString [ "openid" "profile" "email" "groups" ];
        auth_url = "https://dex.0x76.dev/auth";
        token_url = "https://dex.0x76.dev/token";
        api_url = "https://dex.0x76.dev/userinfo";
        skip_org_role_sync = true;
        auto_login = true;
      };

    };
  };
}
