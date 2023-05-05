# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ ... }:

{
  imports = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  # Additional packages
  # environment.systemPackages = with pkgs; [ ];

  networking.firewall.allowedTCPPorts = [ 5055 ];

  virtualisation.podman.enable = true;
  # TODO: Write NixOS package https://github.com/NixOS/nixpkgs/issues/135885
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      overseerr = {
        image = "ghcr.io/sct/overseerr:1.32.5";
        environment = {
          # LOG_LEVEL = "debug";
          TZ = "Europe/Amsterdam";
        };
        ports = [ "5055:5055" ];
        volumes = [ "/var/lib/overseerr/config:/app/config" ];
      };
    };
  };
}
