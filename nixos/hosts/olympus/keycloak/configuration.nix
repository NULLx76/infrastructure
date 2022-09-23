# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let vs = config.vault-secrets.secrets; in
{
  imports = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [ ];

  networking.firewall.allowedTCPPorts = [
    config.services.keycloak.settings.http-port
  ];

  environment.noXlibs = lib.mkForce false;

  vault-secrets.secrets.keycloak = { };

  # If loadCredential doesn't work:
  # https://github.com/NixOS/nixpkgs/issues/157449#issuecomment-1208501368
  services.keycloak = {
    enable = true;
    database = {
      type = "postgresql";
      host = "localhost";
      createLocally = true;
      passwordFile = "${vs.keycloak}/databasePassword"; 
    };
    settings = {
      hostname = "id.0x76.dev";
      proxy = "edge";
      hostname-strict-backchannel = true;
    };
  };

}
