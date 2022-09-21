# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
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
    config.services.outline.port
  ];

  vault-secrets.secrets.outline = { };

  services.outline = {
    enable = true;
    concurrency = 1;
    port = 3000;
    redisUrl = "local";
    databaseUrl = "local";
    publicUrl = "https://outline.0x76.dev";
    utilsSecretFile = "${vs.outline}/utilsSecret";
    secretKeyFile = "${vs.outline}/secretKey";
    storage = {
      accessKey = "outline";
      secretKeyFile = "${vs.outline}/s3key";
      uploadBucketUrl = "https://o.0x76.dev";
      uploadBucketName = "outline";
      region = "us-east-1"; # fake
    };
  };
}
