[
  {
    hostname = "edgerouter";
    ip = "10.42.42.1";
    ip6 = "2001:41f0:9639:1:b6fb:e4ff:fe53:9c0";
    mac = "B4:FB:E4:53:9C:0A";
    nix = false;
  }
  {
    hostname = "unifi-ap";
    ip = "10.42.42.2";
    mac = "b4:fb:e4:f3:ff:1b";
    nix = false;
  }
  {
    hostname = "dhcp";
    ip = "10.42.42.3";
    mac = "3E:2D:E8:AA:E2:81";
  }
  {
    hostname = "bastion";
    ip = "10.42.42.4";
    mac = "82:F0:7C:CB:BD:6D";
    lxc = false;
  }
  {
    hostname = "vault";
    ip = "10.42.42.6";
    mac = "16:2B:87:55:0C:0C";
  }
  {
    hostname = "mosquitto";
    ip = "10.42.42.7";
    mac = "C6:F9:8B:3D:9E:37";
  }
  {
    hostname = "home-assistant";
    ip = "10.42.42.8";
    ip6 = "2001:41f0:9639:1:bfe7:3fd9:75de:cbee";
    mac = "74:40:be:48:85:a4";
    nix = false;
  }
  {
    hostname = "nginx";
    ip = "10.42.42.9";
    mac = "6A:C2:89:85:CF:A6";
  }
  {
    hostname = "k3s-node1";
    profile = "k3s";
    ip = "10.42.42.10";
    mac = "2E:F8:55:23:D9:9B";
    lxc = false;
  }
  {
    hostname = "WoolooTV";
    ip = "10.42.42.13";
    mac = "74:40:be:48:85:a4";
    nix = false;
  }
  {
    hostname = "consul";
    ip = "10.42.42.14";
    mac = "D6:DE:07:41:73:81";
  }
  {
    hostname = "dns-1";
    profile = "dns";
    ip = "10.42.42.15";
    mac = "5E:F6:36:23:16:E3";
  }
  {
    hostname = "dns-2";
    profile = "dns";
    ip = "10.42.42.16";
    mac = "B6:04:0B:CD:0F:9F";
  }
  {
    hostname = "minio";
    ip = "10.42.42.17";
    mac = "0A:06:5E:E7:9A:0C";
  }
  {
    hostname = "nuc";
    ip = "10.42.42.42";
    mac = "1C:69:7A:62:30:88";
    nix = false;
  }
]
