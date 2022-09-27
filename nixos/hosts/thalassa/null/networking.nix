{ ... }:
{
  services.v.dns = {
    enable = true;
    openFirewall = false;
    mode = "laptop";
  };
  networking = {
    useDHCP = true;
    wireless = {
      enable = true;
      environmentFile = "/var/lib/secrets/wireless.env";
      userControlled.enable = true;
      networks = {
        eduroam = {
          auth = ''
            proto=RSN
            key_mgmt=WPA-EAP
            eap=PEAP
            identity="vroest@tudelft.nl"
            password=hash:@EDUROAM_PASSWORD_HASH@
            domain_suffix_match="radius.tudelft.nl"
            anonymous_identity="anonymous@tudelft.nl"
            phase1="peaplabel=0"
            phase2="auth=MSCHAPV2"
            ca_cert="/etc/ssl/certs/ca-bundle.crt"
          '';
        };
        "Pikachu 5G" = {
          psk = "@PIKACHU_PASSWORD@";
        };
      };
    };

    nameservers = [
      "127.0.0.1" # Use locally deployed unbound
      "::1"
    ];

    firewall.allowedUDPPorts = [ 51820 ];

    # Maybe switch to wg-quick
    wireguard.interfaces.wg0 = {
      ips = [ "10.100.0.4/24" ];
      listenPort = 51820;
      privateKeyFile = "/var/lib/secrets/wg_key";

      peers = [
        {
          # Delft
          publicKey = "kDIO3BJSYlDwRXc2zt9tR1LqKJzIPrulaRmdiYkg+m0=";
          allowedIPs = [ "10.100.0.1" "10.42.42.0/23" ];
          endpoint = "195.85.167.34:51820";
          persistentKeepalive = 25;
        }
        {
          # Aerdenhout
          publicKey = "KgqLhmUMX6kyTjRoa/GOCrZOvXNE5HWYuOr/T3v8/VI=";
          allowedIPs = [
            "10.100.0.5"
            "192.168.0.0/24" # to avoid being less specific than a LAN
            "192.168.1.0/24"
            "10.10.10.0/24"
          ];
          endpoint = "80.60.83.220:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
