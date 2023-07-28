# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:
let
  vs = config.vault-secrets.secrets;
  inherit (config.meta.exposes.git) port;
in {
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

  networking.firewall.allowedTCPPorts = [ port ];

  services.openssh.startWhenNeeded = false;

  services.fail2ban = {
    enable = true;
    maxretry = 3;
  };

  vault-secrets.secrets.gitea = {
    user = "gitea";
    group = "gitea";
  };

  system.activationScripts.gitea-theme =
    let target_dir = "${config.services.gitea.stateDir}/custom/public/css/";
    in lib.stringAfter [ "var" ] ''
      mkdir -p ${target_dir}
      ln -sf ${pkgs.v.gitea-agatheme} "${target_dir}/theme-agatheme.css"
    '';

  services.gitea = {
    enable = true;
    package = pkgs.forgejo;
    lfs.enable = true;
    dump.type = "tar.gz";
    database.type = "postgres";
    mailerPasswordFile = "${vs.gitea}/mailPassword";

    settings = {
      default.WORK_PATH = "/var/lib/gitea";
      actions = { "ENABLED" = true; };
      repository = {
        "ENABLE_PUSH_CREATE_USER" = true;
        "DEFAULT_PUSH_CREATE_PRIVATE" = false;
      };
      service = {
        "DEFAULT_KEEP_EMAIL_PRIVATE" = true;
        "DISABLE_REGISTRATION" = true;
      };
      indexer = {
        "REPO_INDEXER_ENABLED" = true;
        "REPO_INDEXER_PATH" = "indexers/repos.bleve";
        "MAX_FILE_SIZE" = 1048576;
        "REPO_INDEXER_EXCLUDE" = "node_modules/**";
      };
      ui = {
        "THEMES" = "gitea,arc-green,agatheme";
        "DEFAULT_THEME" = "agatheme";
        "USE_SERVICE_WORKER" = true;
      };
      server = {
        LANDING_PAGE = "explore";
        SSH_PORT = 42;
        DOMAIN = "git.0x76.dev";
        ROOT_URL = "https://git.0x76.dev";
        HTTP_PORT = port;
      };
      session = {
        "PROVIDER" = "db";
        "COOKIE_SECURE" = true;
      };
      mailer = {
        "ENABLED" = true;
        # "IS_TLS_ENABLED" = true;
        # "HOST" = "mail.0x76.dev:465";
        "FROM" = "gitea@0x76.dev";
        # "MAILER_TYPE" = "smtp";
        "USER" = "gitea@0x76.dev";

        # Below is prep for 1.18
        "PROTOCOL" = "smtps";
        "SMTP_ADDR" = "mail.0x76.dev";
        "SMTP_PORT" = 465;
      };
    };
  };
}
