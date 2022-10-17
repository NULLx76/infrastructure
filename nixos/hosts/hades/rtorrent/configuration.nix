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

  # Mullvad VPN
  networking.wg-quick.interfaces = let 
    postUpScript = pkgs.writeScriptBin "post_up" ''
      #!${pkgs.stdenv.shell}
      ${pkgs.iproute2}/bin/ip route add 10.42.42.0/23 via 192.168.0.1
      ${pkgs.iproute2}/bin/ip route add 10.100.0.0/24 via 192.168.0.1
    '';
  in{
    wg0 = {
      address = [ "10.66.153.191/32" "fc00:bbbb:bbbb:bb01::3:99be/128" ];
      dns = [ "193.138.218.74" ];
      privateKeyFile = "${vs.rtorrent}/wireguardKey";
      postUp = "${postUpScript}/bin/post_up";

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
