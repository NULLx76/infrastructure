# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, config, ... }:
let vs = config.vault-secrets.secrets;
in {
  imports = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [ ];

  vault-secrets.secrets.attic = { services = [ "atticd" ]; };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    ensureDatabases = [ "atticd" ];
    ensureUsers = [{
      name = "atticd";
      ensurePermissions = {
        "DATABASE atticd" = "ALL PRIVILEGES";
        "schema public" = "ALL";
      };
    }];

  };

  services.atticd = {
    enable = true;

    credentialsFile = "${vs.attic}/environment";

    settings = {
      listen = "[::]:8080";
      allowed-hosts = [ "attic.xirion.net" ];
      api-endpoint = "https://attic.xirion.net/";
      require-proof-of-possession = false;

      garbage-collection = {
        interval = "12 hours";
        default-retention-period = "1 month";
      };

      compression = {
        type = "zstd";
        level = 8;
      };

      database.url = "postgresql://atticd?host=/run/postgresql";

      storage = {
        type = "s3";
        region = "hades";
        bucket = "attic";
        endpoint = "http://garage.hades:3900";
      };

      # Data chunking
      #
      # Warning: If you change any of the values here, it will be
      # difficult to reuse existing chunks for newly-uploaded NARs
      # since the cutpoints will be different. As a result, the
      # deduplication ratio will suffer for a while after the change.
      chunking = {
        # The minimum NAR size to trigger chunking
        #
        # If 0, chunking is disabled entirely for newly-uploaded NARs.
        # If 1, all NARs are chunked.
        nar-size-threshold = 64 * 1024; # 64 KiB

        # The preferred minimum size of a chunk, in bytes
        min-size = 16 * 1024; # 16 KiB

        # The preferred average size of a chunk, in bytes
        avg-size = 64 * 1024; # 64 KiB

        # The preferred maximum size of a chunk, in bytes
        max-size = 256 * 1024; # 256 KiB
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];
}
