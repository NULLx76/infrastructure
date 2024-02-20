# Config options needed for various university courses, such as:
# * Wireless IoT and Local Area Networks
# * Network Security
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ docker-compose ];

  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;
  users.extraUsers.vivian.extraGroups = [ "wireshark" "docker" ];

  virtualisation.lxc.enable = true;
  virtualisation.podman.enable = false;
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";
}
