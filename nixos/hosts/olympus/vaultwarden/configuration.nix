# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  vs = config.vault-secrets.secrets;
  cfg = config.services.vaultwarden.config;
in
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

  networking.firewall.allowedTCPPorts = [ cfg.ROCKET_PORT cfg.WEBSOCKET_PORT ];

  vault-secrets.secrets.vaultwarden = {
    user = "vaultwarden";
    group = "vaultwarden";
  };

  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";
    environmentFile = "${vs.vaultwarden}/environment";
    config = {
      DOMAIN = "https://pass.0x76.dev";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = 8222;

      WEBSOCKET_ENABLED = true;
      WEBSOCKET_ADDRESS = "0.0.0.0";
      WEBSOCKET_PORT = 3012;

      SMTP_HOST = "mail.0x76.dev";
      SMTP_FROM = "vaultwarden@0x76.dev";
      SMTP_PORT = 465;
      SMTP_SECURITY = "force_tls";
      SMTP_DEBUG = false;

      SIGNUPS_VERIFY = true;
      SIGNUPS_DOMAINS_WHITELIST = "xirion.net,0x76.dev,meowy.tech";
    };
  };
}
