# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./fs.nix
    ];

  boot.loader.systemd-boot.enable = true;

  networking.hostName = "storage"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.vivian = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Disable firewall, as NFS makes it annoying
  networking.firewall.enable = false;

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?


  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/storage *(rw,async,no_subtree_check,fsid=0,all_squash,anonuid=0,anongid=0)
    '';
  };
}

