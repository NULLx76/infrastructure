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
    clientMaxBodySize = "500m";

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
    virtualHosts."mail.xirion.net" = proxy "http://192.168.0.118";
    virtualHosts."o.xirion.net" = proxy "http://192.168.0.112:9000";
    virtualHosts."requests.xirion.net" = proxy "http://overseerr.hades:5055";
    virtualHosts."pass.xirion.net" = proxy "http://bitwarden_rs";
    virtualHosts."repo.xirion.net" = proxy "http://archlinux";
    virtualHosts."thelounge.xirion.net" = proxy "http://thelounge:9000";

    virtualHosts."registry.xirion.net" = proxy "http://docker-registry:5000"
      // {
        locations."/".extraConfig = ''
          allow 127.0.0.1;
          allow 10.42.42.0/23;
          allow 10.10.10.1/24;
          allow 192.168.0.0/23;
          allow 80.60.83.220;
          allow 195.85.167.32/29;
          deny all;
        '';
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

      locations."api/v1/streaming" = {
        proxyPass = "http://192.168.0.138:55000";
        proxyWebsockets = true;
      };
    };
  };
}
