{ pkgs, ... }: {
  users.extraUsers.jonathan = {
    isNormalUser = true;
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOAXOTU6E06zjK/zkzlSPhTG35PoNRYgTCStEPUYyjeE jonathan@kili"
    ];

    extraGroups = [ ];
  };
}

