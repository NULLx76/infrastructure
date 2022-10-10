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

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # needed as the mailserver configures its down DNS resolver
  networking.extraHosts = ''
    10.42.42.6 vault.olympus
  '';

  vault-secrets.secrets.mailserver = {
    services = [ "dovecot2" "postfix" ];
  };

  mailserver = {
    enable = true;
    fqdn = "mail.0x76.dev";
    domains = [ "0x76.dev" "meowy.tech" ];
    certificateScheme = 3;

    loginAccounts = {
      "v@0x76.dev" = {
        hashedPasswordFile = "${vs.mailserver}/v@0x76.dev";
        aliases = [ "v@meowy.tech" "postmaster@0x76.dev" "postmaster@meowy.tech" ];
      };
      "keycloak@0x76.dev" = {
        hashedPasswordFile = "${vs.mailserver}/keycloak@0x76.dev";
        sendOnly = true;
      };
      "gitea@0x76.dev" = {
        hashedPasswordFile = "${vs.mailserver}/gitea@0x76.dev";
        sendOnly = true;
      };
      "matrix@meowy.tech" = {
        hashedPasswordFile = "${vs.mailserver}/matrix@meowy.tech";
        sendOnly = true;
      };
      "outline@0x76.dev" = {
        hashedPasswordFile = "${vs.mailserver}/outline@0x76.dev";
        sendOnly = true;
      };
      "vaultwarden@0x76.dev" = {
        hashedPasswordFile = "${vs.mailserver}/vaultwarden@0x76.dev";
        sendOnly = true;
      };
    };

    indexDir = "/var/lib/dovecot/indices";
    fullTextSearch = {
      enable = true;
      # index new email as they arrive
      autoIndex = true;
      # this only applies to plain text attachments, binary attachments are never indexed
      indexAttachments = true;
      enforced = "body";
      memoryLimit = 2000;
      autoIndexExclude = [ "\\Junk" ];
    };
  };

  services.postfix.relayHost = "smtp.ziggozakelijk.nl";
  services.postfix.relayPort = 587;

  services.roundcube = {
    enable = true;
    package = pkgs.roundcube.withPlugins (plugins: [ plugins.persistent_login ]);
    plugins = [
      "archive"
      # "enigma"
      # "markasjunk"
      "persistent_login"
    ];
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

  services.nginx = {
    enable = true;
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "v@0x76.dev";
}
