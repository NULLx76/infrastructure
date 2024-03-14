{ config, lib, ... }:
let
  hostAddress = "10.42.99.1";
  hostAddress6 = "fc00::1";
in {
  # TODO: Loop over subdirs, create nixos container for each
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    externalInterface = "ens18";
    # Lazy IPv6 connectivity for the container
    enableIPv6 = true;

    forwardPorts = [

    ];
  };

  # Containers network is
  # * 10.42.99.0/24
  # * fc00:x

  containers = {
  };
}
