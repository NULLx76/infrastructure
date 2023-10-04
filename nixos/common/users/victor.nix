{ pkgs, ... }: {
  # The block that specifies my user account.
  users.extraUsers.victor = {
    # This account is intended for a non-system user.
    isNormalUser = true;

    # My default shell
    shell = pkgs.zsh;

    # My SSH keys.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICBhJAp7NWlHgwDYd2z6VNROy5RkeZHRINFLsFvwT4b3 victor@bastion"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMMbdjysLnmwJD5Fs/SjBPstdIQNUxy8zFHP0GlhHMJB victor@bastion"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIfooZjMWXvXZu1ReOEACDZ0TMb2WJRBSOLlWE8y6fUh victor@aoife"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMTCUjDbDjAiEKbKmLPavuYM0wJIBdjgytLsg1uWuGc victor@nord"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIM3TqXaApX2JZsgfZd7PKVFMecDgqTHKibpSzgdXNpYAAAAABHNzaDo= solov2-le"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+HbsgJTQS6pvnMEI5NPKjIf78z+9A7CTIt3abi+PS6 victor@eevee"
    ];

    # Make me admin
    extraGroups =
      [ "systemd-journal" "wheel" "networkmanager" "libvirtd" "dialout" ];
  };

  home-manager.users.victor = {
    programs = {
      home-manager.enable = true;

      v.git.enable = true;

      tmux = {
        enable = true;
        shortcut = "b";
        terminal = "screen-256color";
        clock24 = true;
      };

      bat.enable = true;
    };
    home = {

      username = "victor";
      homeDirectory = "/home/victor";
      stateVersion = "23.05";
    };

  };
}
