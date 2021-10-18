# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Import common config
      ../../common/generic-lxc.nix
      ../../common
    ];

  networking.hostName = "mosquitto";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [];

  services.mosquitto = {
    users = {};
    enable = true;

    port = 1883;
    host = "0.0.0.0";
    allowAnonymous = true;
    aclExtraConf = "topic readwrite #";
  };

  services.zigbee2mqtt = {
    enable = true;
    dataDir = "/var/lib/zigbee2mqtt";
    settings = {
      homeassistant = false;
      permit_join = true;

      serial = {
        port = "/dev/ttyUSB0";
      };

      mqtt = {
        base_topic = "zigbee2mqtt";
        server = "mqtt://localhost:${toString config.services.mosquitto.port}";
        user = "zigbee2mqtt";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.mosquitto.port ];
}
