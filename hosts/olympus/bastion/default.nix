# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./containers
    # ./vms.nix
  ];

  programs.nix-ld.enable = true;

  meta = {
    ipv4 = "10.42.42.4";
    ipv6 = "2001:41f0:9639:1:80f0:7cff:fecb:bd6d";
    mac = "82:F0:7C:CB:BD:6D";
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  virtualisation.podman.enable = true;

  # Additional packages
  environment.systemPackages = with pkgs; [ vault ];

  networking.useNetworkd = true;
}
