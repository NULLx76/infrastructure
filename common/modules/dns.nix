{ config, pkgs, lib, self, ... }:
# DNS Module to set up Unbound DNS with all my hosts in the config
# Used for DNS Servers and my laptop
with lib;
let
  inherit (builtins) filter attrValues;
  domains = [ "hades" "olympus" "thalassa" ];
  mapConfig = host: {
    inherit (host.config.networking) hostName domain;
    inherit (host.config.meta) ipv4 ipv6;
  };
  hosts = (map mapConfig (attrValues self.nixosConfigurations));
  ipv4Hosts = filter (v: v.ipv4 != null) hosts;
  ipv6Hosts = filter (v: v.ipv6 != null) hosts;

  localData = { hostName, domain, ipv4, ... }: ''"${hostName}.${domain}. A ${ipv4}"'';
  local6Data = { hostName, domain, ipv6, ... }: ''"${hostName}.${domain}. AAAA ${ipv6}"'';
  ptrData = { hostName, domain, ipv4, ... }: ''"${ipv4} ${hostName}.${domain}"'';
  ptr6Data = { hostName, domain, ipv6, ... }: ''"${ipv6} ${hostName}.${domain}"'';

  cfg = config.services.v.dns;
in {
  options.services.v.dns = {
    enable = mkEnableOption "v.dns";

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Whether to open port 53 in the firwall for unbound dns
        And `services.prometheus.exporters.unbound.port` for metrics (if enabled).
      '';
    };

    enableMetrics = mkOption {
      type = types.bool;
      default = cfg.mode == "server";
      description = ''
        Enable prometheus metrics
      '';
    };

    mode = mkOption {
      type = types.enum [ "server" "laptop" ];
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
    services.prometheus.exporters.unbound = mkIf cfg.enableMetrics {
      enable = true;
      inherit (cfg) openFirewall;
      inherit (config.services.unbound) group;
      controlInterface = config.services.unbound.localControlSocketPath;
    };
    services.unbound = {
      enable = true;
      package = pkgs.v.unbound;
      localControlSocketPath =
        mkIf cfg.enableMetrics "/run/unbound/unbound.socket";
      settings = {
        server = mkMerge [
          {
            use-syslog = "yes";
            module-config = ''"validator iterator"'';

            local-zone =
              map (localdomain: ''"${localdomain}}." transparent'') domains;
            local-data = (map localData ipv4Hosts) ++ (map local6Data ipv6Hosts);
            local-data-ptr = (map ptrData ipv4Hosts) ++ (map ptr6Data ipv6Hosts);

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
