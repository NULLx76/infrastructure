# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:
let
  proxy = url: {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = url;
      proxyWebsockets = true;
    };
  };
in {
  imports = [ ];

  nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1t" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.acme.defaults.email = "victorheld12@gmail.com";
  security.acme.acceptTerms = true;
  security.acme.preliminarySelfsigned = true;

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedBrotliSettings = true;
    clientMaxBodySize = "1024m";

    package = pkgs.nginxMainline;

    virtualHosts."cshub.nl" = proxy "http://192.168.0.113";
    virtualHosts."api.cshub.nl" = proxy "http://192.168.0.113";

    virtualHosts."ha.xirion.net" = proxy "http://192.168.0.129:8123";
    virtualHosts."xirion.net" = {
      enableACME = true;
      forceSSL = true;
      locations."/".extraConfig = ''
        add_header Content-Type 'text/html; charset=UTF-8';
        return 200 'Hello, World!';
      '';
      locations."= /.well-known/host-meta".extraConfig = ''
        return 301 https://fedi.xirion.net$request_uri;
      '';
    };
    # virtualHosts."blog.xirion.net" = proxy "http://10.10.10.12";
    virtualHosts."git.xirion.net" = proxy "http://10.10.10.12";
    # virtualHosts."mail.xirion.net" = proxy "http://192.168.0.118";
    virtualHosts."o.xirion.net" = proxy "http://192.168.0.112:9000";
    virtualHosts."g.xirion.net" = proxy "http://garage.hades:3900";
    virtualHosts."requests.xirion.net" = proxy "http://overseerr.hades:5055";
    virtualHosts."pass.xirion.net" = proxy "http://bitwarden_rs";
    virtualHosts."repo.xirion.net" = proxy "http://archlinux";
    virtualHosts."thelounge.xirion.net" = proxy "http://thelounge:9000";
    virtualHosts."attic.xirion.net" = proxy "http://attic.hades:8080";

    virtualHosts."tautulli.xirion.net" = proxy "http://tautulli.hades:8080";
    virtualHosts."peepeepoopoo.xirion.net" = proxy "http://tautulli.hades:8080"; # Deprecated but Ricardo has it bookmarked already!

    virtualHosts."registry.xirion.net" = proxy "http://docker-registry:5000"
      // {
        locations."/".extraConfig = ''
          allow 127.0.0.1;
          allow 10.42.42.0/23;
          allow 10.10.10.1/24;
          allow 192.168.0.0/23;
          allow 80.60.83.220;
          allow 83.128.154.23;
          allow 195.85.167.32/29;
          deny all;
        '';
      };

    virtualHosts."plex.xirion.net" = {
      # Since we want a secure connection, we force SSL
      forceSSL = true;
      enableACME = true;

      extraConfig = ''
        #Some players don't reopen a socket and playback stops totally instead of resuming after an extended pause
        send_timeout 100m;

        # Why this is important: https://blog.cloudflare.com/ocsp-stapling-how-cloudflare-just-made-ssl-30/
        ssl_stapling on;
        ssl_stapling_verify on;

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers on;
        #Intentionally not hardened for security for player support and encryption video streams has a lot of overhead with something like AES-256-GCM-SHA384.
        ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:ECDHE-ECDSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';

        # Forward real ip and host to Plex
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $server_addr;
        proxy_set_header Referer $server_addr;
        proxy_set_header Origin $server_addr;

        # Nginx default client_max_body_size is 1MB, which breaks Camera Upload feature from the phones.
        # Increasing the limit fixes the issue. Anyhow, if 4K videos are expected to be uploaded, the size might need to be increased even more
        client_max_body_size 100M;

        # Plex headers
        proxy_set_header X-Plex-Client-Identifier $http_x_plex_client_identifier;
        proxy_set_header X-Plex-Device $http_x_plex_device;
        proxy_set_header X-Plex-Device-Name $http_x_plex_device_name;
        proxy_set_header X-Plex-Platform $http_x_plex_platform;
        proxy_set_header X-Plex-Platform-Version $http_x_plex_platform_version;
        proxy_set_header X-Plex-Product $http_x_plex_product;
        proxy_set_header X-Plex-Token $http_x_plex_token;
        proxy_set_header X-Plex-Version $http_x_plex_version;
        proxy_set_header X-Plex-Nocache $http_x_plex_nocache;
        proxy_set_header X-Plex-Provides $http_x_plex_provides;
        proxy_set_header X-Plex-Device-Vendor $http_x_plex_device_vendor;
        proxy_set_header X-Plex-Model $http_x_plex_model;

        # Buffering off send to the client as soon as the data is received from Plex.
        proxy_redirect off;
        proxy_buffering off;
      '';
      locations."/" = {

        proxyWebsockets = true;
        proxyPass = "http://plex2.hades:32400/";
      };
    };

    virtualHosts."fedi.xirion.net" = {
      enableACME = true;
      forceSSL = true;

      root = "${pkgs.v.glitch-soc}/public/";
      locations."/".tryFiles = "$uri @proxy";

      # 	location ~ ^/(emoji|packs|system/accounts/avatars|system/media_attachments/files) {
      #     	add_header Cache-Control "public, max-age=31536000, immutable";
      #     	add_header Strict-Transport-Security "max-age=31536000";
      #     	try_files $uri @proxy;
      #   	}

      # 	location /sw.js {
      #     	add_header Cache-Control "public, max-age=0";
      #     	add_header Strict-Transport-Security "max-age=31536000";
      #    		try_files $uri @proxy;
      #   	}

      locations."@proxy" = {
        proxyPass = "http://192.168.0.138:55001";
        proxyWebsockets = true;
      };

      locations."/api/v1/streaming" = {
        proxyPass = "http://192.168.0.138:55000";
        proxyWebsockets = true;
      };
    };

    virtualHosts."fedi-media.xirion.net" = proxy "http://garage.hades:3902";
  };
}
