{ lib, ... }: {
  imports = [ ../common/common.nix ../common/generic-lxc.nix ];

  proxmoxLXC = {
    manageNetwork = true;
    manageHostName = true;
    privileged = false;
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

  system.stateVersion = "23.05";

  users.users.root.initialPassword = "toor";
}
