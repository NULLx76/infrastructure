{ ... }@a:
{
  networking = {
    networkmanager.enable = false;
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

    # Allow reverse path for wireguard
    # firewall = {
    #   # if packets are still dropped, they will show up in dmesg
    #   logReversePathDrops = true;
    #   # wireguard trips rpfilter up
    #   extraCommands = ''
    #     ip46tables -t raw -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
    #     ip46tables -t raw -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
    #   '';
    #   extraStopCommands = ''
    #     ip46tables -t raw -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
    #     ip46tables -t raw -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
    #   '';
    # };
  };
}
