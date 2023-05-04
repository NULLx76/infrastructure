{ pkgs, config, hosts, lib, ... }:
let
  inherit (builtins) filter hasAttr attrValues concatMap;

  proxy = url: {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = url;
      proxyWebsockets = true;
    };
  };
  k8s_proxy = proxy "http://kubernetes.olympus:80/";
  clientConfig = {
    "m.homeserver" = {
      base_url = "https://chat.meowy.tech";
      server_name = "meowy.tech";
    };
    "m.identity_server" = { };
  };
  serverConfig."m.server" = "chat.meowy.tech:443";
  mkWellKnown = data: ''
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';

  hostsWithExposes =
    filter (hasAttr "exposes") (attrValues hosts.${config.networking.domain});
  exposes = { ip, exposes, ... }:
    map ({ domain, port }: { inherit ip domain port; }) (attrValues exposes);
  mkVhost = { ip, domain, port }: {
    "${domain}" = proxy "http://${ip}:${toString port}";
  };
  vhosts = lib.foldr (el: acc: acc // mkVhost el) { }
    (concatMap exposes hostsWithExposes);
in {
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx = {
    enable = true;
    statusPage = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedBrotliSettings = true;
    clientMaxBodySize = "500m";

    package = pkgs.nginxMainline;

    # Templated
    virtualHosts = vhosts // {
      # 0x76.dev
      "ha.0x76.dev" = proxy "http://home-assistant.olympus:8123/";
      "git.0x76.dev" = proxy "http://gitea.olympus:3000";
      "o.0x76.dev" = proxy "http://minio.olympus:9000";
      "grafana.0x76.dev" = proxy "http://victoriametrics.olympus:2342";
      "outline.0x76.dev" = proxy "http://outline.olympus:3000";
      "ntfy.0x76.dev" = proxy "http://ntfy.olympus:80";
      "ci.0x76.dev" = proxy "http://woodpecker.olympus:8000";
      "dex.0x76.dev" = proxy "http://dex.olympus:5556";
      "pass.0x76.dev" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://vaultwarden.olympus:8222";
          proxyWebsockets = true;
        };
        locations."/notifications/hub/negotiate" = {
          proxyPass = "http://vaultwarden.olympus:8222";
          proxyWebsockets = true;
        };
        locations."/notifications/hub" = {
          proxyPass = "http://vaultwarden.olympus:3012";
          proxyWebsockets = true;
        };
      };

      # Redshifts
      "andreea.redshifts.xyz" = proxy "http://zmeura.olympus:8008";

      # Meow
      "meowy.tech" = {
        enableACME = true;
        forceSSL = true;
        locations."/".extraConfig = ''
          add_header Content-Type 'text/html; charset=UTF-8';
          return 200 '<h1>meow</h1>';
        '';
        locations."= /.well-known/matrix/client".extraConfig =
          mkWellKnown clientConfig;
        locations."= /.well-known/matrix/server".extraConfig =
          mkWellKnown serverConfig;
      };
      "chat.meowy.tech" = {
        enableACME = true;
        forceSSL = true;
        locations."/".extraConfig = ''
          return 307 https://element.chat.meowy.tech;
        '';
        locations."/_matrix".proxyPass = "http://synapse.olympus:8008";
        locations."/_synapse/client".proxyPass = "http://synapse.olympus:8008";
        locations."/_synapse/admin" = {
          # Allow only local and my own IPs
          extraConfig = ''
            allow 127.0.0.1;
            allow 10.42.42.0/23;
            allow 192.168.0.0/23;
            allow 80.60.83.220;
            allow 195.85.167.32/29;
            deny all;
          '';
          proxyPass = "http://synapse.olympus:8008";
        };
      };
      "element.chat.meowy.tech" = {
        enableACME = true;
        forceSSL = true;

        root = pkgs.element-web.override {
          conf = {
            default_server_config = clientConfig;
            show_labs_settings = true;
            brand = "chat.meowy.tech";
          };
        };
      };
      "cinny.chat.meowy.tech" = {
        enableACME = true;
        forceSSL = true;

        root = pkgs.cinny.override {
          conf = {
            defaultHomeserver = 0;
            allowCustomHomeservers = false;
            homeserverList = [ "chat.meowy.tech" ];
          };
        };
      };
      "admin.chat.meowy.tech" = {
        enableACME = true;
        forceSSL = true;
        root = pkgs.synapse-admin;
      };
      "books.meowy.tech" = proxy "http://bookwyrm.olympus:8001";

      # Kubernetes endpoints
      "0x76.dev" = k8s_proxy;
      "internal.xirion.net" = k8s_proxy;
      "blog.xirion.net" = k8s_proxy;
    };
  };

  security.acme.defaults.email = "victorheld12@gmail.com";
  security.acme.acceptTerms = true;
  security.acme.preliminarySelfsigned = true;

  services.prometheus.exporters = {
    nginx = {
      enable = true;
      openFirewall = true;
    };
  };
}
