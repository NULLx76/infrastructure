# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, hosts, ... }:
let
  kubeMasterIP = config.deployment.targetHost; # TODO: set more reliably
  kubeMasterHostname =
    "${config.networking.hostName}.${config.networking.domain}";
  kubeMasterAPIServerPort = 6443;
in {
  # resolve master hostname always
  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

  # packages for administration tasks
  environment.systemPackages = with pkgs; [ kompose kubectl kubernetes k9s ];

  # Kubernetes itself
  services.kubernetes = {
    roles = [ "master" "node" ];
    masterAddress = kubeMasterHostname;
    apiserverAddress =
      "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
    easyCerts = true;
    apiserver = {
      securePort = kubeMasterAPIServerPort;
      advertiseAddress = kubeMasterIP;
    };

    # use coredns
    addons.dns.enable = true;

    # needed if you use swap
    kubelet.extraOpts = "--fail-swap-on=false";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  networking.firewall.allowedTCPPorts = [ ];
}
