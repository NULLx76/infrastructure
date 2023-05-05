{ config, pkgs, ... }:
let vs = config.vault-secrets.secrets;
in {
  system.stateVersion = "22.11";

  networking.firewall.allowedTCPPorts = [ 9000 9001 ];

  networking.interfaces.eth0.useDHCP = true;

  vault-secrets.secrets.minio = { };

  services.minio = {
    enable = true;
    rootCredentialsFile = "${vs.minio}/environment";
    package = pkgs.minio_legacy_fs;
  };
}
