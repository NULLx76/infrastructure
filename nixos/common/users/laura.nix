{ pkgs, ... }: {
  users.extraUsers.laura = {
    isNormalUser = true;
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBIlFUUXbwOkhNUjoA6zueTdRuaylgpgFqSe/xWGK9zb laura@zmeura"
    ];

    extraGroups = [ ];
  };
}