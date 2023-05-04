{ config, pkgs, lib, hosts, flat_hosts, ... }:
# DNS Module to set up Unbound DNS with all my hosts in the config
# Used for DNS Servers and my laptop
with lib;
let
  inherit (builtins) filter hasAttr attrNames;
  domains = attrNames hosts;
  ipv4Host = filter (hasAttr "ip") flat_hosts;
  ipv6Hosts = filter (hasAttr "ip6") flat_hosts;

  localData = { hostname, realm, ip, ... }: ''"${hostname}.${realm}. A ${ip}"'';
  local6Data = { hostname, realm, ip6, ... }:
    ''"${hostname}.${realm}. AAAA ${ip6}"'';
  ptrData = { hostname, realm, ip, ... }: ''"${ip} ${hostname}.${realm}"'';
  ptr6Data = { hostname, realm, ip6, ... }: ''"${ip6} ${hostname}.${realm}"'';

  cfg = config.services.v.dns;
in {
  options.services.v.dns = {
    enable = mkEnableOption "v.dns";

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to open port 53 in the firwall for unbound dns
      '';
    };

    mode = mkOption {
      type = types.strMatching "^(server|laptop)$";
      default = "laptop";
      description = ''
        Whether to configure the DNS in server mode (listen on all interfaces) or laptop mode (just on localhost)
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };
    services.unbound = {
      enable = true;
      package = pkgs.v.unbound;
      settings = {
        server = mkMerge [
          {
            use-syslog = "yes";
            module-config = ''"validator iterator"'';

            local-zone =
              map (localdomain: ''"${localdomain}}." transparent'') domains;
            local-data = (map localData ipv4Host) ++ (map local6Data ipv6Hosts);
            local-data-ptr = (map ptrData ipv4Host) ++ (map ptr6Data ipv6Hosts);

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
          }
          (mkIf (cfg.mode == "server") {
            interface-automatic = "yes";
            interface = [ "0.0.0.0" "::0" ];
            access-control = [
              "127.0.0.1/32 allow_snoop"
              "::1 allow_snoop"
              "10.42.0.0/16 allow"
              "127.0.0.0/8 allow"
              "192.168.0.0/23 allow"
              "192.168.2.0/24 allow"
              "::1/128 allow"
            ];
          })
          (mkIf (cfg.mode == "laptop") {
            interface = [ "127.0.0.1" "::1" ];
            access-control = [ "127.0.0.1/32 allow_snoop" "::1 allow_snoop" ];
          })
        ];
      };
    };
  };
}
