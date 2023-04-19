{ config, ... }:
let vs = config.vault-secrets.secrets;
in
{
  networking.interfaces.eth0.useDHCP = true;

  fileSystems."/mnt/storage" = {
    device = "storage:/mnt/storage";
    fsType = "nfs";
  };

  system.stateVersion = "21.11";

  vault-secrets.secrets.unpackerr = { };

  services.unpackerr = {
    enable = true;
    debug = true;
    environmentFile = "${vs.unpackerr}/environment";
    sonarr = {
      url = "http://sonarr2:8989/";
      paths = "/mnt/storage/torrents/r/TV";
    };
    radarr = {
      url = "http://radarr2:7878/";
      paths = "/mnt/storage/torrents/r/Movie";
    };
  };
}

