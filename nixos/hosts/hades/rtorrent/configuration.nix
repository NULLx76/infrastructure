{ config, pkgs, ... }:
let vs = config.vault-secrets.secrets;
in {
  imports = [ ./rtorrent.nix ];
  networking = {
    interfaces.eth0.useDHCP = true;
    firewall = {
      allowedTCPPorts = [ config.services.rtorrent.port ];
      allowedUDPPorts = [ config.services.rtorrent.port ];
    };

    wg-quick.interfaces = let
      postUpScript = pkgs.writeScriptBin "post_up" ''
        #!${pkgs.stdenv.shell}
        ${pkgs.iproute2}/bin/ip route add 10.42.42.0/23 via 192.168.0.1
        ${pkgs.iproute2}/bin/ip route add 10.100.0.0/24 via 192.168.0.1
      '';
    in {
      wg0 = {
        address =
          [ "10.129.112.89/32, fd7d:76ee:e68f:a993:edd1:668b:49f7:b7c3/128" ];
        mtu = 1320;
        dns = [ "10.128.0.1" "fd7d:76ee:e68f:a993::1" ];
        privateKeyFile = "${vs.rtorrent}/wireguardKey";
        postUp = "${postUpScript}/bin/post_up || true";

        peers = [{
          publicKey = "PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=";
          allowedIPs = [ "0.0.0.0/0" "::/0" ];
          endpoint = "europe3.vpn.airdns.org:1637";
          presharedKeyFile = "${vs.rtorrent}/presharedKey";
          persistentKeepalive = 15;
        }];
      };
    };
  };
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
}
