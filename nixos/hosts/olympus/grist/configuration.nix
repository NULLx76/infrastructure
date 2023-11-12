# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, ... }:
let vs = config.vault-secrets.secrets;
in {
  imports = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
  networking.firewall.allowedTCPPorts = [ 8484 ];

  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  vault-secrets.secrets.grist = {
    quoteEnvironmentValues = false; # Needed for docker
    services = [ "podman-grist" ];
  };

  virtualisation.oci-containers.containers.grist = {
    image = "gristlabs/grist:latest";
    environment = {
      APP_HOME_URL = "https://grist.0x76.dev";
      GRIST_SUPPORT_ANON = "false";
      PYTHON_VERSION = "3";
      PYTHON_VERSION_ON_CREATION = "3";

      # Beta OIDC support
      GRIST_OIDC_IDP_ISSUER = "https://dex.0x76.dev";
    };
    environmentFiles = [ "${vs.grist}/environment" ];
    ports = [ "8484:8484" ];
    volumes = [ "/var/lib/grist:/persist" ];
  };
}
