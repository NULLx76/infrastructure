{ config, ... }:
let vs = config.vault-secrets.secrets;
in {
  networking.firewall.allowedTCPPorts = [ 8686 ];

  vault-secrets.secrets.lidarr = {
    quoteEnvironmentValues = false; # Needed for docker
    services = [ "podman-lidarr" ];
  };

  virtualisation.oci-containers.containers.lidarr = {
    image = "randomninjaatk/lidarr-extended:latest";
    extraOptions = [ "--pull=newer" ];
    environment = {
      TZ = "Europe/Amsterdam";
      dlClientSource = "deezer";
      enableVideoScript = "false";
    };
    environmentFiles = [
      # This file defines arlToken
      "${vs.lidarr}/environment"
    ];
    ports = [ "8686:8686" ];
    volumes = [
      "/var/lib/lidarr/config:/config"
      "/var/lib/lidarr/downloads:/downloads-lidarr-extended"
      "/mnt/storage/plex/Music:/music"
      "/mnt/storage/plex/MusicVideos:/music-videos"
    ];
  };
}
