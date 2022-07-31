{ config, pkgs, lib, ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  boot.kernel.sysctl."fs.inotify.max_user_instances" = 2147483647; # INT_MAX, dynamically limited based on available memory
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 1048576;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [ iptables vim ];

  # Disable the firewall as we need all the ports
  networking.firewall.enable = false;

  # Force-enable Cgroupv2
  systemd.enableUnifiedCgroupHierarchy = lib.mkForce true;

  # Ensure `mount` and `grep` are available 
  systemd.services.k3s.path = [ pkgs.gnugrep pkgs.utillinux ];

  # Enable k3s as a master node
  services.k3s = {
    enable = true;
    role = "server";

    extraFlags = builtins.toString [
      "--data-dir=/var/lib/k3s" # Set data dir to var lib
      "--cluster-init" # Enable embedded etcd
      "--disable=servicelb" # disable servicelb
      "--no-deploy=traefik" # we want to configure traefik ourselves (or use nginx instead)
      "--cluster-cidr=10.69.0.0/16" # the default of 10.42.0.0/16 clashes with my own network
    ];
  };
}
