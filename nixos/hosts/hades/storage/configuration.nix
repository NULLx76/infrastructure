{ ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./fs.nix
  ];


  boot.loader.systemd-boot.enable = true;
  services = {

    # Enable the OpenSSH daemon.
    openssh.enable = true;

    nfs.server = {
      enable = true;
      exports = ''
        /mnt/storage *(rw,async,no_subtree_check,fsid=0,all_squash,anonuid=0,anongid=0)
      '';
    };

    snapraid = {
      enable = true;
      parityFiles =
        [ "/mnt/parity1/snapraid.parity" "/mnt/parity2/snapraid.parity" ];
      dataDisks = {
        d1 = "/mnt/disk1";
        d2 = "/mnt/disk2";
        d3 = "/mnt/disk3";
        d4 = "/mnt/disk4";
        d5 = "/mnt/disk5";
        d6 = "/mnt/disk6";
        d7 = "/mnt/disk7";
        # d8 = "/mnt/disk8";
      };
      contentFiles = [
        "/var/lib/snapraid/snapraid.content"
        "/mnt/disk1/snapraid.content"
        "/mnt/disk2/snapraid.content"
        "/mnt/disk3/snapraid.content"
        "/mnt/disk5/snapraid.content"
      ];
      exclude = [
        "/lost+found/"
        "*.tmp"
        "/tmp/"
        "*.unrecoverable"
        "/.Trash-1000/"
        "/rancher/"
        "/torrents/"
        "/exclusion-zone/"
        "/roms/"
      ];
    };
  };

  # Disable firewall, as NFS makes it annoying
  networking.firewall.enable = false;

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11";
}

