# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:
let
  # Redefining the package instead of overriding as overriding GoModules seems broken
  # see: https://github.com/NixOS/nixpkgs/issues/86349
  nuclei-latest = pkgs.buildGoModule rec {
    pname = "nuclei";
    version = "2.9.2";

    src = pkgs.fetchFromGitHub {
      owner = "projectdiscovery";
      repo = pname;
      rev = "1f9a065713924b28b203e2108fc76d7a1ec49068";
      hash = "sha256-QiegMoBy0gZMyQl2MRAwR14zXeh8wvVonyETdAzHbj0=";
    };

    vendorHash = "sha256-0JNwoBqLKH1F/0Tr8o35gCSNT/2plIjIQvZRuzAZ5P8=";

    modRoot = "./v2";
    subPackages = [ "cmd/nuclei/" ];

    doCheck = false;
  };
in
{
  imports = [ ./hardware-configuration.nix ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  # Additional packages
  environment.systemPackages = with pkgs; [
    jq
    jre_minimal
  ];
  boot.loader = {

    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot";
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 25565 ];
  };

  users.extraUsers.laura.extraGroups = [ "wheel" ];
}
