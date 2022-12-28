{ config, pkgs, lib, ... }: {
  imports = [ ./common/common.nix ./common/generic-lxc.nix ];

  proxmoxLXC = {
    manageNetwork = true;
    manageHostName = true;
    privileged = false;
  };
  
  # Enable SSH
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "yes";
    openFirewall = true;
  };

  networking.hostName = lib.mkDefault "template";

  time.timeZone = lib.mkDefault "Europe/Amsterdam";

  networking.useDHCP = true;

  system.stateVersion = "22.11";

  users.users.root.initialPassword = "toor";
}
