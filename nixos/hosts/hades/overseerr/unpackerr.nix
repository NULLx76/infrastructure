{ config, ... }:
let vs = config.vault-secrets.secrets;
in {
  vault-secrets.secrets.unpackerr = { };

  services.unpackerr = {
    enable = true;
    debug = false;
    environmentFile = "${vs.unpackerr}/environment";
    sonarr = {
      url = "http://localhost:8989/";
      paths = "/mnt/storage/torrents/r/TV";
    };
    radarr = {
      url = "http://localhost:7878/";
      paths = "/mnt/storage/torrents/r/Movie";
    };
  };
}
