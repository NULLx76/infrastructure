{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.vmagent;
  settingsFormat = pkgs.formats.json { };
in
{
  options.services.vmagent = {
    enable = mkEnableOption "vmagent";

    user = mkOption {
      default = "vmagent";
      type = types.str;
      description = ''
        User account under which vmagent runs.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "vmagent";
      description = ''
        Group under which vmagent runs.
      '';
    };

    package = mkOption {
      default = pkgs.vmagent;
      defaultText = "pkgs.vmagent";
      type = types.package;
      description = ''
        vmagent package to use. 
      '';
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/vmagent";
      description = ''
        The directory where vmagent stores its data files.
      '';
    };

    remoteWriteUrl = mkOption {
      default = "http://localhost:8428/api/v1/write";
      type = types.str;
      description = ''
        The remote storage endpoint such as VictoriaMetrics 
      '';
    };

    prometheusConfig = mkOption {
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
      };
      description = ''
        Config for prometheus style metrics
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to open the firewall for the default ports.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Create group if set to default
    users.groups = mkIf (cfg.group == "vmagent") { vmagent = { }; };

    # Create user if set to default
    users.users = mkIf (cfg.user == "vmagent") {
      vmagent = {
        group = cfg.group;
        shell = pkgs.bashInteractive;
        description = "vmagent Daemon user";
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };

    # Open firewall if option is set to do so.
    networking.firewall.allowedTCPPorts = mkIf (cfg.openFirewall) [ 8429 ];

    # The actual service
    systemd.services.vmagent =
      let prometheusConfig = settingsFormat.generate "prometheusConfig.yaml" cfg.prometheusConfig;
      in {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        description = "vmagent system service";
        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          Type = "simple";
          Restart = "on-failure";
          WorkingDirectory = cfg.dataDir;
          ExecStart =
            "${cfg.package}/bin/vmagent -remoteWrite.url=${cfg.remoteWriteUrl} -promscrape.config=${prometheusConfig}";
        };
      };

    systemd.tmpfiles.rules = [ "d '${cfg.dataDir}' 0755 ${cfg.user} ${cfg.group} -" ];
  };
}
