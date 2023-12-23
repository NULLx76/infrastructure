# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, config, ... }:
let vs = config.vault-secrets.secrets;
in {
  imports = [ ];

  vault-secrets.secrets.garage = { };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [ ];

  networking.firewall.allowedTCPPorts = [ 3900 3901 3902 ];

  # Defines rpc_secret
  systemd.services.garage.serviceConfig.EnvironmentFile = [ "${vs.garage}/environment" ];

  services.garage = {
    enable = true;
    package = pkgs.garage_0_9;
    settings = {
      db_engine = "lmdb"; # Recommended for mastodon
      replication_mode = "1";
      compression_level = 0;

      # For inter-node comms
      rpc_bind_addr = "[::]:3901";
      rpc_public_addr = "${config.meta.ipv4}:3901";

      # Standard S3 api endpoint
      s3_api = {
        s3_region = "hades";
        api_bind_addr = "[::]:3900";
      };

      # Static file serve endpoint
      s3_web = {
        bind_addr = "[::]:3902";
        root_domain = "g.xirion.net";
      };
    };
  };
}
