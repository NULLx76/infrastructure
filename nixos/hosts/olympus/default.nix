{
  "edgerouter" = {
    ip = "10.42.42.1";
    ip6 = "2001:41f0:9639:1:b6fb:e4ff:fe53:9c0";
    mac = "B4:FB:E4:53:9C:0A";
    nix = false;
  };
  "unifi-ap" = {
    ip = "10.42.42.2";
    mac = "b4:fb:e4:f3:ff:1b";
    nix = false;
  };
  "dhcp" = {
    ip = "10.42.42.3";
    mac = "3E:2D:E8:AA:E2:81";
    tags = [ "networking" ];
  };
  "bastion" = {
    ip = "10.42.42.4";
    ip6 = "2001:41f0:9639:1:80f0:7cff:fecb:bd6d";
    mac = "82:F0:7C:CB:BD:6D";
    type = "vm";
  };
  "vault" = {
    ip = "10.42.42.6";
    mac = "16:2B:87:55:0C:0C";
    profile = "vault-0";
    tags = [ "vault" ];
  };
  "mosquitto" = {
    ip = "10.42.42.7";
    mac = "C6:F9:8B:3D:9E:37";
  };
  "home-assistant" = {
    ip = "10.42.42.8";
    ip6 = "2001:41f0:9639:1:bfe7:3fd9:75de:cbee";
    mac = "9E:60:78:ED:81:B4";
    nix = false;
    exposes.ha = {
      domain = "ha.0x76.dev";
      port = 8123;
    };
  };
  "nginx" = {
    ip = "10.42.42.9";
    ip6 = "2001:41f0:9639:1:68c2:89ff:fe85:cfa6";
    mac = "6A:C2:89:85:CF:A6";
    tags = [ "web" ];
  };
  "kubernetes" = {
    ip = "10.42.42.10";
    mac = "6E:A5:25:99:FE:68";
    exposes = {
      www.domain = "0x76.dev";
      flux.domain = "flux.0x76.dev";
      internal.domain = "internal.xirion.net";
      blog.domain = "blog.xirion.net";
    };
  };
  "dex" = {
    ip = "10.42.42.11";
    mac = "AE:66:7B:FA:15:72";
    exposes = {
      dex = {
        domain = "dex.0x76.dev";
        port = 5556;
      };
      o2p_proxy = {
        domain = "o2p.0x76.dev";
        port = 8484;
      };
    };
  };
  "WoolooTV" = {
    ip = "10.42.42.13";
    mac = "74:40:be:48:85:a4";
    nix = false;
  };
  "outline" = {
    ip = "10.42.42.14";
    mac = "52:13:EB:FD:87:F0";
    exposes.outline = {
      domain = "outline.0x76.dev";
      port = 3000;
    };
  };
  "dns-1" = {
    profile = "dns";
    ip = "10.42.42.15";
    mac = "5E:F6:36:23:16:E3";
    tags = [ "dns" "networking" ];
  };
  "dns-2" = {
    profile = "dns";
    ip = "10.42.42.16";
    mac = "B6:04:0B:CD:0F:9F";
    tags = [ "dns" "networking" ];
  };
  "minio" = {
    ip = "10.42.42.17";
    mac = "0A:06:5E:E7:9A:0C";
    exposes.minio = {
      domain = "o.0x76.dev";
      port = 9000;
    };
  };
  "mailserver" = {
    ip = "10.42.42.18";
    mac = "AA:F2:3D:5E:B3:40";
  };
  "victoriametrics" = {
    ip = "10.42.42.19";
    mac = "9E:91:61:35:84:1F";
    exposes = {
      grafana = {
        domain = "grafana.0x76.dev";
        port = 2342;
      };
    };
  };
  "unifi" = {
    ip = "10.42.42.20";
    mac = "1A:88:A0:B0:65:B4";
  };
  "minecraft" = {
    ip = "10.42.42.21";
    mac = "EA:30:73:E4:B6:69";
    nix = false;
  };
  "gitea" = {
    ip = "10.42.42.22";
    mac = "DE:5F:B0:83:6F:34";
    exposes.git = {
      domain = "git.0x76.dev";
      port = 3000;
    };
  };
  "hedgedoc" = {
    ip = "10.42.42.23";
    mac = "86:BC:0C:18:BC:9B";
    exposes.md = {
      domain = "md.0x76.dev";
      port = 3000;
    };
  };
  "zmeura" = {
    ip = "10.42.42.24";
    mac = "b8:27:eb:d5:e0:f5";
    nix = false;
    exposes.andreea = {
      domain = "andreea.redshifts.xyz";
      port = 8008;
    };
  };
  "wireguard" = {
    ip = "10.42.42.25";
    mac = "1E:ED:97:2C:C3:9D";
  };
  "grist" = {
    ip = "10.42.42.26";
    mac = "B2:AA:AB:5D:2F:22";
    exposes.grist = {
      domain = "grist.0x76.dev";
      port = 8484;
    };
  };
  "bookwyrm" = {
    ip = "10.42.42.27";
    mac = "9E:8A:6C:39:27:DE";
    nix = false;
    exposes.books = {
      domain = "books.meowy.tech";
      port = 8001;
    };
  };
  "synapse" = {
    ip = "10.42.42.28";
    mac = "9E:86:D3:46:EE:AE";
  };
  # 10.42.42.29
  "vault-1" = {
    ip = "10.42.42.30";
    mac = "26:69:0E:7C:B3:79";
    profile = "vault-1";
    tags = [ "vault" ];
  };
  "vaultwarden" = {
    ip = "10.42.42.31";
    mac = "96:61:03:16:63:98";
  };
  "ntfy" = {
    ip = "10.42.42.32";
    mac = "7A:17:9E:80:72:01";
    exposes.ntfy.domain = "ntfy.0x76.dev";
  };
  "ci" = {
    ip = "10.42.42.33";
    mac = "1E:24:DA:DB:4A:1A";
  };
  "nuc" = {
    ip = "10.42.42.42";
    ip6 = "2001:41f0:9639:1::42";
    mac = "1C:69:7A:62:30:88";
    nix = false;
  };
  "shield" = {
    ip = "10.42.42.43";
    ip6 = "2001:41f0:9639:1::43";
    mac = "48:b0:2d:4e:29:c0";
    nix = false;
  };
  "eevee" = {
    ip = "10.42.42.69";
    ip6 = "2001:41f0:9639:1:a83:e416:dc99:5ed3";
    mac = "34:97:f6:93:9A:AA";
    type = "local";
  };
}
