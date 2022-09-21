# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, inputs, ... }:
let
  db_name = "hedgedoc";
  db_user = "hedgedoc";
  vs = config.vault-secrets.secrets;
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

  environment.noXlibs = lib.mkForce false;

  networking.firewall.allowedTCPPorts = [ config.services.hedgedoc.settings.port ];

  vault-secrets.secrets.hedgedoc = { };

  services.postgresql =
    {
      enable = true;
      package = pkgs.postgresql_13;
      ensureDatabases = [ db_name ];
      ensureUsers = [
        {
          name = db_user;
          ensurePermissions = { "DATABASE ${db_name}" = "ALL PRIVILEGES"; };
        }
      ];
    };

  services.hedgedoc = {
    enable = true;
    environmentFile = "${vs.hedgedoc}/environment";
    settings = {
      host = "0.0.0.0";
      port = 3000;
      sessionSecret = "$SESSION_SECRET";
      domain = "md.0x76.dev";
      protocolUseSSL = true;
      hsts.enable = true;
      allowOrigin = [
        config.services.hedgedoc.settings.domain
        "hedgedoc"
      ];
      allowAnonymous = false;
      allowEmailRegister = false;
      allowAnonymousEdits = true;
      allowFreeURL = true;
      requireFreeURLAuthentication = true;
      imageUploadType = "minio";
      db = {
        dialect = "postgres";
        username = db_user;
        database = db_name;
        host = "/run/postgresql";
      };
      s3bucket = "hedgedoc";
      minio = {
        secure = true;
        endPoint = "o.0x76.dev";
        port = 443;
        accessKey = "$MINIO_ACCESS_KEY";
        secretKey = "$MINIO_SECRET_KEY";
      };
      email = true;
    };
  };
}
