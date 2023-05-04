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
  system.stateVersion = "22.11"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [ ntfy-sh ];

  networking.firewall.allowedTCPPorts = [ 80 ];

  services.ntfy-sh = let datadir = "/var/lib/ntfy";
  in {
    enable = true;
    settings = {
      base-url = "https://ntfy.0x76.dev";
      listen-http = ":80";
      cache-file = "${datadir}/cache.db";
      auth-file = "${datadir}/user.db";
      auth-default-access = "deny-all";
      behind-proxy = true;
      attachment-cache-dir = "${datadir}/attachments";
    };
  };
}
