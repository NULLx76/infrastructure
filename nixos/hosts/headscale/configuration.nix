# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, inputs, ... }:
{
  imports = [ ];

  networking.hostName = "headscale";

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

  networking.firewall.allowedTCPPorts = [ config.services.headscale.port 50443 ];

  services.postgresql =
    let
      db_name = config.services.headscale.database.name;
      db_user = config.services.headscale.database.user;
    in
    {
      enable = false;
      package = pkgs.postgresql_13;
      ensureDatabases = [ db_name ];
      authentication = "host ${db_name} ${db_user} 127.0.0.1/32 trust";
      ensureUsers = [
        {
          name = db_user;
          ensurePermissions = { "DATABASE ${db_name}" = "ALL PRIVILEGES"; };
        }
      ];
    };

  services.headscale = {
    enable = false;
    address = "0.0.0.0";
    serverUrl = "https://vpn.0x76.dev";
    logLevel = "debug";

    settings = {
      grpc_listen_addr = "0.0.0.0:50443";
      grpc_allow_insecure = true;

      ip_prefixes = [
        "fd7a:115c:a1e0::/48"
        "100.64.0.0/10"
      ];
    };

    database = {
      type = "postgres";
      port = config.services.postgresql.port;
      name = "headscale";
      user = "headscale";
      host = "127.0.0.1";
    };
  };

  systemd.services.headscale.environment = {
    GIN_MODE = "release";
  };
}
