{ lib, ... }: {
  # TODO: Loop over subdirs, create nixos container for each
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    externalInterface = "ens18";
    # Lazy IPv6 connectivity for the container
    enableIPv6 = true;
  };

  # Containers network is
  # * 10.42.99.0/24
  # * fc00:x

  containers.monitoring = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.42.99.1";
    localAddress = "10.42.99.2";
    hostAddress6 = "fc00::1";
    localAddress6 = "fc00::2";

    config = {
      imports = [ ./monitoring ];
      # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
      networking.useHostResolvConf = lib.mkForce false;
      services.resolved.enable = true;
    };
  };
}
