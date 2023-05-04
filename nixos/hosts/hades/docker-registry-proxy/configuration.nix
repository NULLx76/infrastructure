{ config, ... }:
let vs = config.vault-secrets.secrets;
in {
  system.stateVersion = "22.05";

  networking.interfaces.eth0.useDHCP = true;

  # the registry port and metrics port
  networking.firewall.allowedTCPPorts =
    [ config.services.dockerRegistry.port 5001 ];

  vault-secrets.secrets.docker-registry = { };

  # Sets the minio user and password
  systemd.services.docker-registry.serviceConfig.EnvironmentFile =
    "${vs.docker-registry}/environment";

  services.dockerRegistry = {
    enable = true;
    enableDelete = true;
    enableGarbageCollect = true;
    listenAddress = "0.0.0.0";
    storagePath = null; # We want to store in s3
    garbageCollectDates = "weekly";
    extraConfig = {
      # S3 Storages
      storage.s3 = {
        regionendpoint = "https://o.xirion.net";
        bucket = "docker-registry-proxy";
        region = "us-east-1"; # Fake but needed
      };

      # The actual proxy
      proxy.remoteurl = "https://registry-1.docker.io";

      # Enable prom under :5001/metrics
      http.debug.addr = "0.0.0.0:5001";
      http.debug.prometheus.enabled = true;
    };
  };
}

