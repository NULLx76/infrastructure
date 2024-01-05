{ lib, config, ... }:
with lib;
let
  exposesOpts = {
    options = {
      domain = mkOption {
        type = types.str;
        example = "<name>.example.com";
        description = lib.mdDoc ''
          The domain under which this service should be available
        '';
      };
      port = mkOption {
        type = types.int;
        default = 80;
        example = 4242;
        description = lib.mdDoc ''
          The port under which the service runs on the host
        '';
      };
    };
  };
in {
  options.meta = {
    exposes = mkOption {
      type = with types; attrsOf (submodule exposesOpts);
      default = { };
      description = ''
        Exposed services
      '';
    };

    ipv4 = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = lib.mdDoc ''
        Host's IPv4 Address
      '';
    };

    ipv6 = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = lib.mdDoc ''
        Host's IPv6 address
      '';
    };

    mac = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = lib.mdDoc ''
        Own MAC Address
      '';
    };

    isLaptop = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Is this host a Laptop (i.e. no DNS entries should be made).
      '';
    };

    realm = mkOption {
      readOnly = true;
      type = types.nullOr (types.enum [ "thalassa" "hades" "olympus" ]);
      default = config.networking.domain;
      defaultText = literalExpression "config.network.domain";
    };
  };

  config = {
    # TODO: Open Firewall

    assertions = [
      {
        assertion = config.meta.mac != null;
        message =
          "${config.networking.fqdnOrHostName} is missing a mac address";
      }
      {
        assertion = !config.meta.isLaptop -> config.meta.ipv4 != null;
        message =
          "${config.networking.fqdnOrHostName} needs ipv4 address set as it is not a laptop";
      }
    ];
  };
}
