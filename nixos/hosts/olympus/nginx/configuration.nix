{ pkgs, ... }:
let
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
in
{
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services = {

    # Generates vhosts for all hosts that have an `exposes` section
    v.nginx.autoExpose = true;

    nginx = {
      enable = true;
      statusPage = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedBrotliSettings = true;
      clientMaxBodySize = "500m";

      package = pkgs.nginxMainline;

      # Templated
      virtualHosts = {
        "pass.0x76.dev" = {
          enableACME = true;
          forceSSL = true;
          locations = {

            "/".proxyPass = "http://vaultwarden.olympus:8222";
            "/".proxyWebsockets = true;

            "/notifications/hub/negotiate" = {
              proxyPass = "http://vaultwarden.olympus:8222";
              proxyWebsockets = true;
            };
            "/notifications/hub" = {
              proxyPass = "http://vaultwarden.olympus:3012";
              proxyWebsockets = true;
            };
          };
        };

        # Meow
        "meowy.tech" = {
          enableACME = true;
          forceSSL = true;
          locations = {
            "/".extraConfig = ''
              add_header Content-Type 'text/html; charset=UTF-8';
              return 200 '<h1>meow</h1>';
            '';
            "= /.well-known/matrix/client".extraConfig =
              mkWellKnown clientConfig;
            "= /.well-known/matrix/server".extraConfig =
              mkWellKnown serverConfig;
          };
        };
        "chat.meowy.tech" = {
          enableACME = true;
          forceSSL = true;
          locations = {
            "/".extraConfig = ''
              return 307 https://element.chat.meowy.tech;
            '';
            "/_matrix".proxyPass = "http://synapse.olympus:8008";
            "/_synapse/client".proxyPass = "http://synapse.olympus:8008";
            "/_synapse/admin" = {
              # Allow only local and my own IPs
              extraConfig = ''
                allow 127.0.0.1;
                allow 10.42.42.0/23;
                allow 192.168.0.0/23;
                allow 80.60.83.220;
                allow 83.128.154.23;
                allow 195.85.167.32/29;
                deny all;
              '';
              proxyPass = "http://synapse.olympus:8008";
            };
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
      };
    };

    prometheus.exporters = {
      nginx = {
        enable = true;
        openFirewall = true;
      };
    };
  };
  security = {
    acme = {

      defaults.email = "vivian@0x76.dev";
      acceptTerms = true;
      preliminarySelfsigned = true;
    };
  };
}
