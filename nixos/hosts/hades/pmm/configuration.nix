# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:
let
  datadir = "/var/lib/pmm/config";
  container = "meisnate12/plex-meta-manager:latest";
  run_pmm = pkgs.writeScriptBin "pmm-run" ''
    sudo ${pkgs.podman}/bin/podman run --rm -it \
      -v "/var/lib/pmm/config:/config:rw" \
      -v "/etc/pmm/Anime.yml:/config/Anime.yml:ro" \
      -v "/etc/pmm/Movies.yml:/config/Movies.yml:ro" \
      -v "/etc/pmm/TVShows.yml:/config/TVShows.yml:ro" \
    ${container} --run
  '';
in {
  imports = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  networking.firewall.allowedTCPPorts = [ ];

  environment.etc.pmm.source = ./config;

  environment.systemPackages = [ run_pmm ];

  virtualisation.podman.enable = true;
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      plex-meta-manager = {
        image = container;
        volumes = [
          "${datadir}:/config:rw"
          "/etc/pmm/Anime.yml:/config/Anime.yml:ro"
          "/etc/pmm/Movies.yml:/config/Movies.yml:ro"
          "/etc/pmm/TVShows.yml:/config/TVShows.yml:ro"
        ];
      };
    };
  };
}
