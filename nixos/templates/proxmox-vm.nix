{ lib, ... }: {
  imports = [ ../common/common.nix ../common/generic-vm.nix ];

  proxmox.qemuConf = {
    virtio0 = "local-zfs:vm-9999-disk-0";
    cores = 1;
    memory = 1024;
    bios = "ovmf";
  };

  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes";
    };
    openFirewall = true;
  };

  networking.hostName = lib.mkDefault "template";

  time.timeZone = lib.mkDefault "Europe/Amsterdam";

  networking.useDHCP = true;

  system.stateVersion = "23.05";

  users.users.root.initialPassword = "toor";
}
