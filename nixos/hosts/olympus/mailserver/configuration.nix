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

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  networking.extraHosts = ''
    10.42.42.6 vault.olympus
  '';

  vault-secrets.secrets.mailserver = {
    services = [ "dovecot2" "postfix"];
  };

  mailserver = {
    enable = true;
    fqdn = "mail.0x76.dev";
    domains = [ "0x76.dev" ];

    loginAccounts = {
      "v@0x76.dev" = {
        hashedPasswordFile = "${vs.mailserver}/v@0x76.dev";
      };
    };

    certificateScheme = 3;
  };

  services.roundcube = {
     enable = true;
     # this is the url of the vhost, not necessarily the same as the fqdn of
     # the mailserver
     hostName = "webmail.0x76.dev";
     extraConfig = ''
       # starttls needed for authentication, so the fqdn required to match
       # the certificate
       $config['smtp_host'] = "tls://${config.mailserver.fqdn}";
       $config['smtp_user'] = "%u";
       $config['smtp_pass'] = "%p";
     '';
  };

  services.nginx.enable = true;

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "victor@xirion.net";
}
