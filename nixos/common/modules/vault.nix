{ config, pkgs, lib, flat_hosts, inputs, ... }:
with lib;
let
  cfg = config.services.v.vault;
  hostIP = config.deployment.targetHost;

  vault_hosts =
    filter ({ tags ? [ ], ip ? "", ... }: (elem "vault" tags) && (ip != hostIP))
    flat_hosts;
  cluster_config = concatStrings (map ({ ip, ... }: ''
    retry_join {
      leader_api_addr = "http://${ip}:${toString cfg.port}"
    }
  '') vault_hosts);
in {
  options.services.v.vault = {
    enable = mkEnableOption "v.vault";

    node_id = mkOption {
      type = types.str;
      description = ''
        The cluster node id of this node
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to open port port and clusterPort in the firewall for vault
      '';
    };

    port = mkOption {
      type = types.int;
      default = 8200;
      description = ''
        The port vault listens on
        **note:** this has to be the same for all nodes in a cluster
      '';
    };

    clusterPort = mkOption {
      type = types.int;
      default = 8201;
      description = ''
        The cluster port vault listens on
        **note:** this has to be the same for all nodes in a cluster
      '';
    };

    autoUnseal = mkOption {
      type = types.bool;
      default = false;
      description = ''
        whether to auto-unseal this vault
      '';
    };

    autoUnsealTokenPath = mkOption {
      type = types.str;
      default = null;
      example = "/var/lib/vault-unseal/keys.json";
      description = ''
        auto unseal tokens to use
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = cfg.autoUnseal -> (cfg.autoUnsealTokenPath != null);
      message = "If autoUnseal is enabled, a token path is required!";
    }];

    networking.firewall.allowedTCPPorts =
      mkIf cfg.openFirewall [ cfg.port cfg.clusterPort ];

    services.vault = {
      enable = true;
      # bin version includes the UI
      package = pkgs.vault-bin;
      address = "0.0.0.0:${toString cfg.port}";
      storageBackend = "raft";
      storagePath = "/var/lib/vault-raft";
      storageConfig = ''
        node_id = "${cfg.node_id}"
      '' + cluster_config;
      extraConfig = ''
        ui = true
        disable_mlock = true
        api_addr = "http://${hostIP}:${toString cfg.port}"
        cluster_addr = "http://${hostIP}:${toString cfg.clusterPort}"
      '';
    };

    systemd.services.vault-unseal = mkIf cfg.autoUnseal {
      description = "Vault unseal service";
      wantedBy = [ "multi-user.target" ];
      after = [ "vault.service" ];
      environment = {
        VAULT_ADDR = "http://localhost:${toString cfg.port}";
        VAULT_KEY_FILE = cfg.autoUnsealTokenPath;
      };
      serviceConfig = {
        User = "vault";
        Group = "vault";
        Type = "simple";
        Restart = "on-failure";
        ExecStart = "${
            inputs.vault-unseal.packages.${pkgs.system}.default
          }/bin/vault-unseal";
      };
    };
  };
}
