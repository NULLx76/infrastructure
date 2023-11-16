# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  vs = config.vault-secrets.secrets;
  db_user = "dex";
  db_name = "dex";
  inherit (config.meta.exposes.dex) port;
  metricsPort = 5558;
in {
  imports = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  networking.firewall.allowedTCPPorts = [ port metricsPort ];

  vault-secrets.secrets.dex = { };
  vault-secrets.secrets.oauth2_proxy = { };

  services = {

    postgresql = {
      enable = true;
      package = pkgs.postgresql_15;
      ensureDatabases = [ db_name ];
      ensureUsers = [{
        name = db_user;
        ensurePermissions = {
          "DATABASE ${db_name}" = "ALL PRIVILEGES";
          "schema public" = "ALL";
        };
      }];
    };

    dex = {
      enable = true;
      settings = {
        issuer = "https://dex.0x76.dev";
        storage = {
          type = "postgres";
          config = {
            host = "/var/run/postgresql";
            user = db_user;
            database = db_name;
          };
        };
        web.http = "0.0.0.0:${toString port}";
        telemetry.http = "0.0.0.0:${toString metricsPort}";
        connectors = [{
          type = "gitea";
          id = "gitea";
          name = "Gitea";
          config = {
            clientID = "$GITEA_CLIENT_ID";
            clientSecret = "$GITEA_CLIENT_SECRET";
            redirectURI = "https://dex.0x76.dev/callback";
            baseURL = "https://git.0x76.dev";
          };
        }];

        staticClients = [
          {
            id = "outline";
            name = "Outline";
            redirectURIs = [ "https://outline.0x76.dev/auth/oidc.callback" ];
            secretEnv = "OUTLINE_CLIENT_SECRET";
          }
          {
            id = "grafana";
            name = "Grafana";
            redirectURIs = [ "https://grafana.0x76.dev/login/generic_oauth" ];
            secretEnv = "GRAFANA_CLIENT_SECRET";
          }
          {
            id = "hedgedoc";
            name = "Hedgedoc";
            redirectURIs = [ "https://md.0x76.dev/auth/oauth2/callback" ];
            secretEnv = "HEDGEDOC_CLIENT_SECRET";
          }
          {
            id = "flux";
            name = "Weave Gitops Flux Dashboard";
            redirectURIs = [ "https://flux.0x76.dev/oauth2/callback" ];
            secretEnv = "FLUX_CLIENT_SECRET";
          }
          {
            id = "grist";
            name = "grist";
            redirectURIs = [ "https://grist.0x76.dev/oauth2/callback" ];
            secretEnv = "GRIST_CLIENT_SECRET";
          }
        ];
      };

      environmentFile = "${vs.dex}/environment";
    };
  };
}
