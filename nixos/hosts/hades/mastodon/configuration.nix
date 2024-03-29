{ config, pkgs, lib, ... }:
let
  vs = config.vault-secrets.secrets;
  cfg = config.services.mastodon;
in {
  system.stateVersion = "21.05";
  # Use DHCP with static leases
  networking.interfaces.eth0.useDHCP = true;

  # Better cache hits
  environment.noXlibs = lib.mkForce false;
  services = {
    elasticsearch = {
      enable = true;
      cluster_name = "mastodon-es";
      package = pkgs.elasticsearch7;
    };

    postgresql = {
      enable = true;
      package = pkgs.postgresql_16;
      settings = {
        shared_preload_libraries = "pg_stat_statements";
        "pg_stat_statements.track" = "all";
        "pg_stat_statements.max" = 10000;
        track_activity_query_size = 2048;
      };
      # The rest of the database setup is handled by mastodon
    };

    mastodon = {
      enable = true;
      package = pkgs.v.glitch-soc;
      streamingProcesses = 3;
      webPort = 55001;
      enableUnixSocket = false;
      localDomain = "xirion.net";
      trustedProxy = "192.168.0.122";
      mediaAutoRemove = {
        enable = true;
        olderThanDays = 30;
        startAt = "daily";
      };

      configureNginx = false;

      redis.createLocally = true;

      elasticsearch = {
        host = "127.0.0.1";
        inherit (config.services.elasticsearch) port;
      };

      database.createLocally = true;

      smtp = {
        createLocally = false;
        fromAddress = "mastodon@xirion.net";
        host = "mail.0x76.dev";
        user = "mastodon@xirion.net";
        authenticate = true;
        port = 587;
        passwordFile = "${vs.mastodon}/smtp-password";
      };

      extraConfig = {
        BIND = "0.0.0.0";
        SINGLE_USER_MODE = "false";
        EMAIL_DOMAIN_ALLOWLIST = "xirion.net";
        DEFAULT_LOCALE = "en";

        WEB_DOMAIN = "fedi.xirion.net";
        ALTERNATE_DOMAINS = "meowy.tech";

        SMTP_AUTH_METHOD = "plain";
        SMTP_OPENSSL_VERIFY_MODE = "none";

        RAILS_SERVE_STATIC_FILES = "false";

        AUTHORIZED_FETCH = "true";

        # https://github.com/cybrespace/cybrespace-meta/blob/master/s3.md;
        # https://shivering-isles.com/Mastodon-and-Amazon-S3
        S3_ENABLED = "true";
        S3_REGION = "hades";
        S3_BUCKET = "mastodon";
        S3_ENDPOINT = "http://garage.hades:3900";
        S3_ALIAS_HOST = "fedi-media.xirion.net";

        DEEPL_PLAN = "free";
      };
    };
  };

  vault-secrets.secrets.mastodon = {
    services = [ "mastodon-init-dirs" "mastodon" "mastodon-media-autoremove" ];
    inherit (cfg) user group;
  };

  # Append the init-dirs script to add AWS/Minio secrets
  systemd.services.mastodon-init-dirs.script = ''
    cat >> /var/lib/mastodon/.secrets_env <<EOF
    AWS_ACCESS_KEY_ID="$(cat ${vs.mastodon}/garageKeyId)"
    AWS_SECRET_ACCESS_KEY="$(cat ${vs.mastodon}/garageSecretKey)"
    DEEPL_API_KEY="$(cat ${vs.mastodon}/deeplAPIKey)"
    EOF
  '';

  networking.firewall = let cfg = config.services.mastodon;
  in { allowedTCPPorts = [ cfg.webPort ]; };
}
