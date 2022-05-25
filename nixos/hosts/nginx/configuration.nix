{ config, pkgs, ... }:
let
  proxy = url: {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = url;
      proxyWebsockets = true;
    };
  };
  k8s_proxy = proxy "http://10.42.42.150:8000/";
in
{
  networking.hostName = "nginx";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [ ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;

    package = pkgs.nginxMainline.override {
      modules = with pkgs.nginxModules; [ brotli ];
    };

    # Reverse Proxies
    virtualHosts."ha.0x76.dev" = proxy "http://home-assistant.olympus:8123/";
    virtualHosts."zookeeper-dev.0x76.dev" = proxy "http://eevee.olympus:8085/";
    virtualHosts."md.0x76.dev" = proxy "http://hedgedoc.olympus:3000/";
    virtualHosts."git.0x76.dev" = proxy "http://gitea.olympus:3000";
    virtualHosts."o.0x76.dev" = proxy "http://minio.olympus:9000";

    # Kubernetes endpoints
    virtualHosts."0x76.dev" = k8s_proxy;
    virtualHosts."id.0x76.dev" = k8s_proxy;
    virtualHosts."agola.0x76.dev" = k8s_proxy;
    virtualHosts."zookeeper.0x76.dev" = k8s_proxy;
    virtualHosts."wooloofan.club" = k8s_proxy;
    virtualHosts."whoami.wooloofan.club" = k8s_proxy;
  };

  services.nginx.commonHttpConfig = ''
    brotli on;
    brotli_comp_level 6;
    brotli_static on;
    brotli_types application/atom+xml application/javascript application/json application/rss+xml
                application/vnd.ms-fontobject application/x-font-opentype application/x-font-truetype
                application/x-font-ttf application/x-javascript application/xhtml+xml application/xml
                font/eot font/opentype font/otf font/truetype image/svg+xml image/vnd.microsoft.icon
                image/x-icon image/x-win-bitmap text/css text/javascript text/plain text/xml;
  '';

  security.acme.defaults.email = "victorheld12@gmail.com";
  security.acme.acceptTerms = true;
  security.acme.preliminarySelfsigned = true;
}
