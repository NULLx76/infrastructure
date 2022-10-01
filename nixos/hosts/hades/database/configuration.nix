{ config, pkgs, ... }:
let vs = config.vault-secrets.secrets;
in {

  system.stateVersion = "21.05";
  networking.interfaces.eth0.useDHCP = true;

  networking.firewall.allowedTCPPorts = [ config.services.postgresql.port ];

  vault-secrets.secrets.database = {
    user = "postgres";
    group = "postgres";
    services = [ "postgresql" ];
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_13;
    enableTCPIP = true;
    extraPlugins = [ ];
    initdbArgs = [
      "--encoding 'UTF-8'"
      "--lc-collate='en_US.UTF-8'"
      "--lc-ctype='en_US.UTF-8'"
    ];
    authentication = ''
      host all all 192.168.0.1/23 md5
      host all all  10.10.10.0/24 md5
    '';
    initialScript = "${vs.database}/initialScript";
    settings = {
      shared_preload_libraries = "pg_stat_statements";
      "pg_stat_statements.track" = "all";
      "pg_stat_statements.max" = 10000;
      track_activity_query_size = 2048;
    };
  };
}
