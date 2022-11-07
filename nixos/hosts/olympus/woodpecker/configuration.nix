# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let vs = config.vault-secrets.secrets;
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

  networking.firewall.allowedTCPPorts = [ ];

  vault-secrets.secrets.woodpecker = {
    services = [ "podman-woodpecker-server" "podman-woodpecker-agent" ];
    quoteEnvironmentValues = false; # Needed for docker
  };

  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      woodpecker-server = {
        image = "woodpeckerci/woodpecker-server:latest";
        ports = [ "8000:8000" ];
        volumes = [ "woodpecker-server-data:/var/lib/woodpecker/" ];
        environmentFiles = [ "${vs.woodpecker}/environment" ];
        environment = {
          WOODPECKER_OPEN = "true";
          WOODPECKER_HOST = "https://ci.0x76.dev";
          WOODPECKER_GITEA = "true";
          WOODPECKER_GITEA_URL = "https://git.0x76.dev";
          WOODPECKER_ADMIN = "v";
        };
      };
      woodpecker-agent = {
        image = "woodpeckerci/woodpecker-agent:latest";
        dependsOn = [ "woodpecker-server" ];
        cmd = [ "agent" ];
        volumes = [ "/var/run/docker.sock:/var/run/docker.sock" ];
        environmentFiles = [ "${vs.woodpecker}/environment" ];
        environment = { WOODPECKER_SERVER = "woodpecker-server:9000"; };
      };
    };
  };
}
