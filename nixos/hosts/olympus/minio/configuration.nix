# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  vs = config.vault-secrets.secrets;
  listenPort = config.meta.exposes.minio.port;
  consolePort = listenPort + 1;
in
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

  networking.firewall.allowedTCPPorts = [ listenPort consolePort ];

  vault-secrets.secrets.minio = { };

  services.minio = {
    enable = true;
    package = pkgs.minio_legacy_fs;
    rootCredentialsFile = "${vs.minio}/environment";
    listenAddress = ":${toString listenPort}";
    consoleAddress = ":${toString consolePort}";
  };

  # services.garage = {
  #   enable = true;
  #   replication_mode = "1";
  #   package = pkgs.garage_0_8;
  #   settings = {
  #     s3_api = {
  #       api_bind_addr = "0.0.0.0:3900";
  #       s3_region = "olympus";
  #     };
  #   };
  # };
}
