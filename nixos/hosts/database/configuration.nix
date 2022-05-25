# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  databases = [ "authentik" ];

in
{
  imports = [ ];

  networking.hostName = "database";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [ ];

  networking.firewall.allowedTCPPorts = [ config.services.postgresql.port ];

  services.postgresql =
    {
      enable = true;
      package = pkgs.postgresql_14;
      ensureDatabases = databases;
      enableTCPIP = true;
      # Allow all hosts on the server subnet, should probably lock this down more in the future
      authentication = "host all all 10.42.42.0/24 trust";
      ensureUsers = map
        (name: {
          inherit name;
          ensurePermissions = { "DATABASE ${name}" = "ALL PRIVILEGES"; };
        })
        databases;
    };
}
