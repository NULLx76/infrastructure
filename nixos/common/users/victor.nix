{ pkgs, ... }: {
    # The block that specifies my user account.
  users.extraUsers.victor = {
    # This account is intended for a non-system user.
    isNormalUser = true;

    # My default shell
    shell = pkgs.zsh;

    # My SSH keys.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKME+A5zu36tMIsY+PBoboizgAzt6xReUNrKRBkxvl3i victor@null"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC8llUcEBHsLqotFZc++LNP2fjItuuzeUsu5ObXecYNj victor@eevee"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICBhJAp7NWlHgwDYd2z6VNROy5RkeZHRINFLsFvwT4b3 victor@bastion"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMMbdjysLnmwJD5Fs/SjBPstdIQNUxy8zFHP0GlhHMJB victor@bastion"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIfooZjMWXvXZu1ReOEACDZ0TMb2WJRBSOLlWE8y6fUh victor@aoife"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIM3TqXaApX2JZsgfZd7PKVFMecDgqTHKibpSzgdXNpYAAAAABHNzaDo= solov2-le"
    ];

    # Make me admin
    extraGroups = [ "systemd-journal" "wheel" "networkmanager" "libvirtd" ];
  };
}
