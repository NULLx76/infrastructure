{ config, pkgs, ... }:
let vs = config.vault-secrets.secrets;
in {
  imports = [ ./rtorrent.nix ];

  networking.interfaces.eth0.useDHCP = true;
  system.stateVersion = "22.05";

  fileSystems."/mnt/storage" = {
    device = "storage:/mnt/storage";
    fsType = "nfs";
  };

  services.flood = {
    enable = true;
    host = "0.0.0.0";
    openFirewall = true;
    inherit (config.services.rtorrent) downloadDir;
  };

  vault-secrets.secrets.rtorrent = { services = [ "wg-quick-wg0" ]; };

  # Mullvad VPN
  networking.wg-quick.interfaces = let
    postUpScript = pkgs.writeScriptBin "post_up" ''
      #!${pkgs.stdenv.shell}
      ${pkgs.iproute2}/bin/ip route add 10.42.42.0/23 via 192.168.0.1
      ${pkgs.iproute2}/bin/ip route add 10.100.0.0/24 via 192.168.0.1
    '';
  in {
    wg0 = {
      address = [ "10.66.153.191/32" "fc00:bbbb:bbbb:bb01::3:99be/128" ];
      dns = [ "10.64.0.1" ];
      privateKeyFile = "${vs.rtorrent}/wireguardKey";
      postUp = "${postUpScript}/bin/post_up || true";

      peers = [
        {
          publicKey = "33BoONMGCm2vknq2eq72eozRsHmHQY6ZHEEZ4851TkY=";
          allowedIPs = [ "0.0.0.0/0" "::/0"];
          endpoint = "193.32.249.70:51820";
          persistentKeepalive = 25;
        }
        # {
        # publicKey = "DVui+5aifNFRIVDjH3v2y+dQ+uwI+HFZOd21ajbEpBo=";
        # allowedIPs = [ "0.0.0.0/0" "::/0" ];
        # endpoint = "185.65.134.82:51820";
        # persistentKeepalive = 25;
        # }
      ];
    };
  };
}
