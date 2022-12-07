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
  networking.firewall.checkReversePath = false;

  vault-secrets.secrets.wireguard = {
    services = [ "wireguard-wg0" ];
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [ "wg0" "eth0" ];
    externalInterface = "eth0";
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
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
      {
        # Old Laptop
        publicKey = "L8myt2bcdja7M+i+9eatdQRW8relPUoZZ9lEKSLe+m8=";
        allowedIPs = [ "10.100.0.4/32" ];
      }
      {
        # New Laptop
        publicKey = "+Ms3xV6LxNZWTQk11zoz+AUIV2uds6A64Wz15JlR/Ak=";
        allowedIPs = [ "10.100.0.5/32" ];
      }
      {
        # Aerdenhout
        # Useful setup video for opnsense: https://www.youtube.com/watch?v=RoXHe5dqCM0
        # https://docs.opnsense.org/manual/how-tos/wireguard-s2s.html
        publicKey = "KgqLhmUMX6kyTjRoa/GOCrZOvXNE5HWYuOr/T3v8/VI=";
        allowedIPs = [ "10.100.0.5/32" "192.168.0.0/23" "10.10.10.0/24" ];
        endpoint = "80.60.83.220:51820";
        persistentKeepalive = 25;
      }
    ];
  };
}
