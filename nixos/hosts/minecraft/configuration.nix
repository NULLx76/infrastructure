# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports = [ ];

  networking.hostName = "minecraft";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [ ];

  services.minecraft-server = {
    enable = true;
    declarative = true;
    eula = true;
    openFirewall = true;
    serverProperties = {
      server-port = 25565;
      motd = "blahaj minecraft server!";
      white-list = true;
    };
    whitelist = {
      "0x76" = "5513404a-81a2-4c84-b952-18661b1803e7";
    };

    package = pkgs.papermc;
  };
}
