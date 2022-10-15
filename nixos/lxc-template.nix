{ config, pkgs, lib, ... }: {
  # Can't import common completely due to infinite recursion
  imports = [ ./common/users ./common/generic-lxc.nix ];

  # Enable SSH
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "yes";
  };

  time.timeZone = lib.mkDefault "Europe/Amsterdam";

  networking.interfaces.eth0.useDHCP = true;

  system.stateVersion = "22.11";
}
