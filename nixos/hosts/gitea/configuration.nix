# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:
{
  imports = [ ];

  networking.hostName = "gitea";

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

  networking.firewall.allowedTCPPorts = [ config.services.gitea.httpPort ];

  services.gitea = {
    enable = true;
    domain = "git.0x76.dev";
    rootUrl = "https://git.0x76.dev";
    lfs.enable = true;
    dump.type = "tar.gz";
    database.type = "postgres";
    ssh.clonePort = 42;
    disableRegistration = true;
    cookieSecure = true;
    

    settings = {
      ui = {
        DEFAULT_THEME = "arc-green";
        USE_SERVICE_WORKER = true;
      };
    };
  };
}
