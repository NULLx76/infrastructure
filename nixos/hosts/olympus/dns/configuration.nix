{ config, pkgs, hosts, flat_hosts, ... }:
let
  inherit (builtins) filter hasAttr attrNames;
  domains = attrNames hosts;
  ipv4Host = filter (hasAttr "ip") flat_hosts;
  ipv6Hosts = filter (hasAttr "ip6") flat_hosts;

  localData = { hostname, realm, ip, ... }: ''"${hostname}.${realm}. A ${ip}"'';
  local6Data = { hostname, realm, ip6, ... }: ''"${hostname}.${realm}. AAAA ${ip6}"'';
  ptrData = { hostname, realm, ip, ... }: ''"${ip} ${hostname}.${realm}"'';
  ptr6Data = { hostname, realm, ip6, ... }: ''"${ip6} ${hostname}.${realm}"'';
in {
  imports = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [ dig dog drill ];

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  services.unbound = {
    enable = true;
    package = pkgs.unbound;
    settings = {
      server = {
        use-syslog = "yes";
        module-config = ''"validator iterator"'';
        interface-automatic = "yes";
        interface = [ "0.0.0.0" "::0" ];

        local-zone = map (localdomain: ''"${localdomain}}." transparent'') domains;
        local-data = (map localData ipv4Host) ++ (map local6Data ipv6Hosts);
        local-data-ptr = (map ptrData ipv4Host) ++ (map ptr6Data ipv6Hosts);

        access-control = [
          "127.0.0.1/32 allow_snoop"
          "::1 allow_snoop"
          "10.42.0.0/16 allow"
          "127.0.0.0/8 allow"
          "192.168.0.0/23 allow"
          "192.168.2.0/24 allow"
          "::1/128 allow"
        ];
        private-address = [
          "127.0.0.0/8"
          "10.0.0.0/8"
          "::ffff:a00:0/104"
          "172.16.0.0/12"
          "::ffff:ac10:0/108"
          "169.254.0.0/16"
          "::ffff:a9fe:0/112"
          "192.168.0.0/16"
          "::ffff:c0a8:0/112"
          "fd00::/8"
          "fe80::/10"
        ];
      };
    };
  };
}
