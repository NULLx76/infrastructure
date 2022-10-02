{ config, pkgs, lib, ... }:
let
  vs = config.vault-secrets.secrets;
  cfg = config.services.mastodon;
in
{
  system.stateVersion = "21.05";
  # Use DHCP with static leases
  networking.interfaces.eth0.useDHCP = true;

  # Better cache hits
  environment.noXlibs = lib.mkForce false;

  services.elasticsearch = {
    enable = true;
    cluster_name = "mastodon-es";
    package = pkgs.elasticsearch7;
  };

  vault-secrets.secrets.mastodon = {
    services = [ "mastodon-init-dirs" "mastodon" ];
    user = cfg.user;
    group = cfg.group;
  };

  # Append the init-dirs script to add AWS/Minio secrets
  systemd.services.mastodon-init-dirs.script = ''
    cat >> /var/lib/mastodon/.secrets_env <<EOF
    AWS_ACCESS_KEY_ID="$(cat ${vs.mastodon}/awsAccessKeyId)"
    AWS_SECRET_ACCESS_KEY="$(cat ${vs.mastodon}/awsSecretAccessKey)"
    EOF
  '';

  services.mastodon = {
    enable = true;
    package = pkgs.v.glitch-soc;
    streamingPort = 55000;
    webPort = 55001;
    enableUnixSocket = false;
    localDomain = "xirion.net";
    trustedProxy = "192.168.0.123";

    configureNginx = false;

    redis = { createLocally = true; };

    elasticsearch = {
      host = "127.0.0.1";
      port = config.services.elasticsearch.port;
    };

    database = {
      createLocally = false;
      user = "mastodon";
      passwordFile = "${vs.mastodon}/db-password";
      port = 5432;
      name = "mastodon";
      host = "192.168.0.126";
    };

    smtp = {
      createLocally = false;
      fromAddress = "mastodon@xirion.net";
      host = "mail.xirion.net";
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

      SMTP_AUTH_METHOD = "plain";
      SMTP_OPENSSL_VERIFY_MODE = "none";

      # TODO: Don't?
      RAILS_SERVE_STATIC_FILES = "true";

      # https://github.com/cybrespace/cybrespace-meta/blob/master/s3.md;
      # https://shivering-isles.com/Mastodon-and-Amazon-S3
      S3_ENABLED = "true";
      S3_BUCKET = "mastodon";
      S3_PROTOCOL = "https";
      S3_HOSTNAME = "o.xirion.net";
      S3_ENDPOINT = "https://o.xirion.net/";
    };
  };

  networking.firewall =
    let cfg = config.services.mastodon;
    in { allowedTCPPorts = [ cfg.streamingPort cfg.webPort ]; };
}
