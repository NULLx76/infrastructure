{ config, pkgs, flat_hosts, ... }:
let
  inherit (builtins) filter hasAttr;
  hostToDhcp = { hostname, mac, ip, ... }: {
    ethernetAddress = mac;
    hostName = hostname;
    ipAddress = ip;
  };
  hostToKea = {hostname, mac, ip, ...}: {
    inherit hostname;
    hw-address = mac;
    ip-address = ip;
  };
  localDomain = config.networking.domain;
  hosts =
    filter (h: hasAttr "ip" h && hasAttr "mac" h && h.realm == localDomain)
    flat_hosts;
in {
  networking = {
    defaultGateway = "10.42.42.1";
    nameservers = [ "10.42.42.15" "10.42.42.16" ];
    interfaces.eth0 = {
      useDHCP = false; # It turns out the barber just doesn't shave
      ipv4.addresses = [{
        address = "10.42.42.3";
        prefixLength = 23;
      }];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [ ];

  networking.firewall.allowedUDPPorts = [ 67 ];

  services.dhcpd4 = {
    enable = true;
    extraConfig = ''
      option subnet-mask 255.255.254.0;
      option broadcast-address 10.42.43.255;
      option routers 10.42.42.1;
      option domain-name-servers 10.42.42.15, 10.42.42.16;
      option domain-name "${localDomain}";
      option domain-search "${localDomain}";
      subnet 10.42.42.0 netmask 255.255.254.0 {
        range 10.42.43.1 10.42.43.254;
      }
    '';
    machines = map hostToDhcp hosts;
  };

  services.kea = {
    dhcp4 = {
      enable = false;
      settings = {
        authoritative = true;
        valid-lifetime = 4000;
        rebind-timer = 2000;
        renew-timer = 1000;

        interfaces-config.interfaces = [ "eth0" ];

        lease-database = {
          name = "/var/lib/kea/dhcp4.leases";
          persist = true;
          type = "memfile";
        };

        option-data = [
          {
            name = "subnet-mask";
            data = "255.255.254.0";
          }
          {
            name = "broadcast-address";
            data = "10.42.43.255";
          }
          {
            name = "routers";
            data = "10.42.42.1";
          }
          {
            name = "domain-name-servers";
            data = "10.42.42.15, 10.42.42.16";
          }
          {
            name = "domain-name";
            data = "${localDomain}";
          }
          {
            name = "domain-search";
            data = "${localDomain}";
          }
        ];

        host-reservation-identifiers = [ "hw-address" ];

        subnet4 = [{
          id = 1;
          pools = [{ pool = "10.42.43.1 - 10.42.43.254"; }];
          subnet = "10.42.42.0/23";
          reservations = map hostToKea hosts;
        }];
      };
    };
  };
}
