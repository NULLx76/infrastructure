{ lib, ... }:
with lib;
let
  exposesOpts = {
    options = {
      domain = mkOption {
        type = types.str;
        example = "<name>.example.com";
        description = ''
          The domain under which this service should be available
        '';
      };
      port = mkOption {
        type = types.int;
        default = 80;
        example = 4242;
        description = ''
          The port under which the service runs on the host
        '';
      };
    };
  };
in
{
  options.meta = {

    exposes = mkOption {
      type = with types; attrsOf (submodule exposesOpts);
      description = ''
        Exposed services
      '';
    };

    ipv4 = mkOption {
      type = types.str;
      description = ''
        Own IPv4 Address
      '';
    };
  };

  config = { };
}
