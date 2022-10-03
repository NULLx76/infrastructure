{ config, pkgs, ... }:
let vs = config.vault-secrets.secrets; in
{
  imports = [
    ./rtorrent.nix
  ];

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
    downloadDir = config.services.rtorrent.downloadDir;
  };

  vault-secrets.secrets.rtorrent = {
    services = [ "wg-quick-wg0" ];
  };

  # # basically to override wireguard and route olympus IPs via the router
  # networking.interfaces.eth0.ipv4.routes = [{
  #   address = "10.42.42.0";
  #   prefixLength = 23;
  #   via = "192.168.0.1";
  # }];

  # Mullvad VPN
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.66.153.191/32" "fc00:bbbb:bbbb:bb01::3:99be/128" ];
      dns = [ "193.138.218.74" ];
      privateKeyFile = "${vs.rtorrent}/wireguardKey";
      postUp = "${pkgs.iproute2}/bin/ip route add 10.42.42.0/23 via 192.168.0.1";

      peers = [
        {
          publicKey = "hnRorSW0YHlHAzGb4Uc/sjOqQIrqDnpJnTQi/n7Rp1c=";
          allowedIPs = [ "0.0.0.0/0" "::/0" ];
          endpoint = "185.65.134.223:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
