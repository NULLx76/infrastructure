# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, config, ... }:
let
  # https://github.com/immich-app/immich/releases
  # version = "1.55.1";
  dataDir = "/var/lib/immich";
in {
  imports = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [ ];

  # TODO: https://github.com/suderman/nixos/tree/main/modules/nixos/immich

  fileSystems."/mnt/storage" = {
    device = "storage:/mnt/storage";
    fsType = "nfs";
  };
  ids = {
    # Unused uid/gid snagged from this list:
    # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/misc/ids.nix
    uids.immich = 911;
    gids.immich = 911;
  };
  users = {
    groups = {
      photos = { };
      immich = { gid = config.ids.gids.immich; };
    };

    users.immich = {
      isSystemUser = true;
      group = "photos";
      description = "Immich daemon user";
      home = dataDir;
      uid = config.ids.uids.immich;
    };
  };

  # Postgres database configuration
  services.postgresql = {
    enable = true;

    package = pkgs.postgresql_15;

    ensureUsers = [{
      name = "immich";
      ensureDBOwnership = true;
    }];
    ensureDatabases = [ "immich" ];

    # Allow connections from any docker IP addresses
    authentication = ''
      host immich immich 172.16.0.0/12 md5
      host all all 127.0.0.1/32 ident
    '';

  };

  # Allow docker containers to connect
  networking.firewall.allowedTCPPorts = [ config.services.postgresql.port ];
}
