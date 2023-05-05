# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, ... }:
let
  vs = config.vault-secrets.secrets;
  inherit (config.meta.exposes.outline) port;
in {
  imports = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  # Additional packages
  networking.firewall.allowedTCPPorts = [ port ];

  vault-secrets.secrets.outline = {
    inherit (config.services.outline) user group;
  };

  services.outline = {
    inherit port;

    enable = true;
    concurrency = 1;
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
    oidcAuthentication = {
      displayName = "Dex";
      userinfoUrl = "https://dex.0x76.dev/userinfo";
      tokenUrl = "https://dex.0x76.dev/token";
      clientId = "outline";
      authUrl = "https://dex.0x76.dev/auth";
      clientSecretFile = "${vs.outline}/dexClientSecret";
    };
    smtp = rec {
      username = "outline@0x76.dev";
      fromEmail = username;
      replyEmail = username;
      secure = true;
      port = 465;
      host = "mail.0x76.dev";
      passwordFile = "${vs.outline}/mailPassword";
    };
  };
}
