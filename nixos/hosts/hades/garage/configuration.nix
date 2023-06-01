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

  # Additional packages
  environment.systemPackages = with pkgs; [ ];

  networking.firewall.allowedTCPPorts = [ ];

  # See also: https://github.com/NixOS/nixpkgs/tree/master/nixos/tests/garage
  services.garage = {
    enable = false;
    package = pkgs.garage_0_8;
    settings = {
      # rpc_bind_addr = "[::]:3901"
      # rpc_public_addr = "127.0.0.1:3901"
      # rpc_secret = "$(openssl rand -hex 32)"

      # [s3_api]
      # s3_region = "garage"
      # api_bind_addr = "[::]:3900"
      # root_domain = ".s3.garage.localhost"

      # [s3_web]
      # bind_addr = "[::]:3902"
      # root_domain = ".web.garage.localhost"
      # index = "index.html"

      # [k2v_api]
      # api_bind_addr = "[::]:3904"

      # [admin]
      # api_bind_addr = "0.0.0.0:3903"
      # admin_token = "$(openssl rand -base64 32)"
    };
  };
}
