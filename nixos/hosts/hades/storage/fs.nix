{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
    smartmontools
  ];
  fileSystems = {
    "/mnt/disk1" = {
      fsType = "ext4";
      device = "/dev/disk/by-partuuid/abbfc440-fb3d-4b33-92cb-948b2deeac53";
    };

    "/mnt/disk2" = {
      fsType = "ext4";
      device = "/dev/disk/by-partuuid/3a57ffa8-8a0f-4839-81df-7f34d99e9dbc";
    };

    "/mnt/disk3" = {
      fsType = "ext4";
      device = "/dev/disk/by-partuuid/0f72c5f8-b7db-4151-83f0-47e5f703aeb1";
    };

    "/mnt/disk4" = {
      fsType = "ext4";
      device = "/dev/disk/by-partuuid/b9c72b41-1538-436e-a595-49d1faa5ed01";
    };

    "/mnt/disk5" = {
      fsType = "ext4";
      device = "/dev/disk/by-partuuid/928d0200-eca1-4a69-b2d6-fbd23a5ee8cd";
    };

    "/mnt/disk6" = {
      fsType = "ext4";
      device = "/dev/disk/by-uuid/63381321-fe00-4838-8668-4d1decc94296";
    };

    "/mnt/disk7" = {
      fsType = "ext4";
      device = "/dev/disk/by-uuid/6c568887-9d2e-45ce-ab85-4c48cca2226a";
    };

    "/mnt/parity1" = {
      fsType = "ext4";
      device = "/dev/disk/by-partuuid/7c9b88ed-b8f8-40c9-bbc3-b75d30e04e01";
    };

    "/mnt/parity2" = {
      fsType = "ext4";
      device = "/dev/disk/by-partuuid/5d2d7e3e-3730-4d9b-8759-dc14396f3357";
    };

    "/mnt/storage" = {
      fsType = "fuse.mergerfs";
      device = "/mnt/disk*";
      options = [
        "direct_io"
        "defaults"
        "allow_other"
        "minfreespace=20G"
        "fsname=mergerfs"
        "use_ino"
        "noforget"
        "moveonenospc=true"
        "category.create=mfs"
      ];
    };
  };
}
