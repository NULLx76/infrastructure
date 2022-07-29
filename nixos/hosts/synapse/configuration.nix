# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  vs = config.vault-secrets.secrets;
  port = 8008;
  metricsPort = 9000;
in
{
  imports = [ ];

  networking.hostName = "synapse";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [ ];

  networking.firewall.allowedTCPPorts = [ port metricsPort ];

  vault-secrets.secrets.synapse = {
    user = "matrix-synapse";
    group = "matrix-synapse";
    services = [ "matrix-synapse" ];
  };

  services.postgresql = {
    enable = true;
    initialScript = pkgs.writeText "synapse-init.sql" ''
      CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
      CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";
    '';
  };

  services.matrix-synapse =
    let
      extraConfig = builtins.toFile "extraConfig.yaml" ''
        registration_requires_token: true
      '';
    in
    {
      enable = true;
      withJemalloc = true;

      extraConfigFiles = [
        "${vs.synapse}/macaroon_secret_key"
        "${vs.synapse}/registration_shared_secret"
        "${vs.synapse}/form_secret"
        "${vs.synapse}/turn_shared_secret"
        extraConfig
      ];

      settings =
        {
          server_name = "meowy.tech";
          enable_registration = true;
          public_baseurl = "https://chat.meowy.tech";
          enable_metrics = true;
          listeners = [
            {
              inherit port;
              bind_addresses = [ "0.0.0.0" ];
              type = "http";
              tls = false;
              x_forwarded = true;
              resources = [
                {
                  names = [ "client" "federation" ];
                  compress = true;
                }
              ];
            }
            {
              port = metricsPort;
              bind_addresses = [ "0.0.0.0" ];
              type = "metrics";
              tls = false;
              resources = [
                {
                  names = [ "metrics" ];
                  compress = false;
                }
              ];
            }
          ];
        };
    };
}
