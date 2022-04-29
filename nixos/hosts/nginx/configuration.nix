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
in {
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

    # Reverse Proxies
    virtualHosts."ha.0x76.dev" = proxy "http://home-assistant.olympus:8123/";
    virtualHosts."zookeeper-dev.0x76.dev" = proxy "http://eevee.olympus:8085/";
    virtualHosts."analytics.0x76.dev" = proxy "http://plausible.olympus:8000/";
    virtualHosts."git.0x76.dev" = proxy "http://gitea.olympus:3000";

    # Kubernetes endpoints
    virtualHosts."0x76.dev" = k8s_proxy;
    virtualHosts."zookeeper.0x76.dev" = k8s_proxy;
    virtualHosts."wooloofan.club" = k8s_proxy;
    virtualHosts."whoami.wooloofan.club" = k8s_proxy;
  };

  security.acme.defaults.email = "victorheld12@gmail.com";
  security.acme.acceptTerms = true;
  security.acme.preliminarySelfsigned = true;
}
