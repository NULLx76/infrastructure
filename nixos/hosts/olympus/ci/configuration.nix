# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  vs = config.vault-secrets.secrets;
in {
  imports = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [ ];

  vault-secrets.secrets.gitea_runner = {
    services = [ "gitea-runner-nix\x2dnative" ];
  };

  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    dockerCompat = true;
    autoPrune.enable = true;
  };

  # Thanks to: https://blog.kotatsu.dev/posts/2023-04-21-woodpecker-nix-caching/

  # Fix DNS Lookup in podman
  virtualisation.podman.defaultNetwork.settings.dns_enable = true;
  networking.firewall.interfaces."podman+" = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };

  services.gitea-actions-runner.instances = {
    nix-native = {
      enable = true;
      name = "nix-native";
      labels = [ "native:host" ];
      url = "https://git.0x76.dev";
      tokenFile = "${vs.gitea_runner}/token_native";
      hostPackages = with pkgs; [
        bash
        coreutils
        curl
        deadnix
        gawk
        gitMinimal
        gnused
        jq
        nixUnstable
        nodejs
        statix
        vault
        wget
        yamllint
      ];
    };
  };
}
