# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, inputs, ... }:
let vs = config.vault-secrets.secrets; in
{
  imports = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [ wireguard-tools ];

  environment.noXlibs = lib.mkForce false;

  networking.firewall.allowedUDPPorts = [
    config.networking.wireguard.interfaces.wg0.listenPort
  ];

  vault-secrets.secrets.wireguard = {
    services = [ "wireguard-wg0" ];
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [ "wg0" ];
    externalInterface = "eth0";
  };

  services.prometheus.exporters.wireguard = {
    enable = true;
    openFirewall = true;
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = "${vs.wireguard}/privateKey";

    peers = [
      {
        # Phone
        publicKey = "K+99mvSYs4urcclreQDLA1pekD4xtu/mpS2uVWw8Bws=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
      {
        # Laura's laptop
        publicKey = "ZWIaDGrASlTkEK75j10VeGCvrIGfpk4GPobmqcYX2D0=";
        allowedIPs = [ "10.100.0.3/32" ];
      }
    ];
  };
}
