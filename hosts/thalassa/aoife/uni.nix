# Config options needed for various university courses, such as:
# * Wireless IoT and Local Area Networks
# * Network Security
# * Smart Phone Sensing
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    android-studio
    docker-compose
    bridge-utils
    nettools
    wget
  ];

  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;

  virtualisation.lxc.enable = false;
  virtualisation.lxd.enable = false;

  virtualisation.podman.enable = false;
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  users.extraUsers.vivian.extraGroups = [
    "wireshark"
    "docker"
    "lxd"
  ];

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
    libraries = [

    ];
  };
}
