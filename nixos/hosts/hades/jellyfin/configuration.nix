# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  imports = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  boot.tmp.useTmpfs = true;

  # Additional packages
  environment.systemPackages = with pkgs; [ ];

  fileSystems."/mnt/storage" = {
    device = "storage:/mnt/storage";
    fsType = "nfs";
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  users.groups.watchstate = { };
  users.users.watchstate = {
    isSystemUser = true;
    group = "watchstate";
  };

  systemd.tmpfiles.rules =
    [ "d '/var/lib/watchstate' 0755 watchstate watchstate -" ];

  networking.firewall.allowedTCPPorts = [ 8080 ];

  # Managed imperatively through its CLI
  virtualisation.oci-containers.containers.watchstate = {
    image = "ghcr.io/arabcoders/watchstate:latest";
    extraOptions = [ "--pull=newer" ];
    user = "0:0";
    environment = {
      WS_TZ = "Europe/Amsterdam";
      WS_CRON_IMPORT = "1";
      WS_CRON_EXPORT = "1";
      WS_CRON_PROGRESS = "1";
    };
    ports = [ "8080:8080" ];
    volumes = [ "/var/lib/watchstate:/config:rw" ];
  };

}
