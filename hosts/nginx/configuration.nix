# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Import common config
    ../../common/generic-lxc.nix
    ../../common
  ];

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


    virtualHosts."ha.0x76.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.42.42.8:8123/";
        proxyWebsockets = true;
      };
    };

    virtualHosts."zookeeper.0x76.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.42.43.28:8085/";
        proxyWebsockets = true;
      };
    };

    # TODO: Make a function for adding hostnames to k8s endpoint(s).
    virtualHosts."wooloofan.club" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.42.42.150:8000/";
        proxyWebsockets = true;
      };
    };

    virtualHosts."whoami.wooloofan.club" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://10.42.42.150:8000/";
        proxyWebsockets = true;
      };
    };
  };

  security.acme.email = "victorheld12@gmail.com";
  security.acme.acceptTerms = true;
}
