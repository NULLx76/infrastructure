# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, pkgs_22-11, ... }:

{
  imports = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [ ];

  networking.firewall.allowedTCPPorts = [ 8443 ];

  environment.noXlibs = lib.mkForce false;

  services.unifi = {
    enable = true;
    unifiPackage = pkgs.unifi;
    # /nix/store/wlk5idiz9kqkans7j3vxp7bgg03xc2c6-mongodb-3.6.13/bin/mongod --noauth --dbpath /var/lib/unifi/data/db --journal
    # https://www.reddit.com/r/UNIFI/comments/lpwpyk/unifi_controller_any_version_mongodb_36_nearing/
    mongodbPackage = pkgs_22-11.mongodb-3_6; # TODO: Upgrade 3.6 to 4.2
    openFirewall = true;
  };
}
