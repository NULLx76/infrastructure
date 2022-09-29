# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, hosts, ... }:
let 
  port = 8200;
  clusterPort = 8201;
in {
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [ ];

  # Vault
  networking.firewall.allowedTCPPorts = [ port clusterPort ];

  services.vault = {
    enable = true;
    # bin version includes the UI
    package = pkgs.vault-bin;
    address = "0.0.0.0:${toString port}";
    storageBackend = "raft";
    storagePath = "/var/lib/vault-raft";
    storageConfig = ''
      node_id = "hades-1"

      retry_join {
        leader_api_addr = "http://10.42.42.30:${toString port}"
      }

      retry_join {
        leader_api_addr = "http://10.42.42.6:${toString port}"
      }
    '';
    extraConfig = ''
      ui = true
      disable_mlock = true
      api_addr = "http://192.168.0.103:${toString port}"
      cluster_addr = "http://192.168.0.103:${toString clusterPort}"
    '';
  };
}
