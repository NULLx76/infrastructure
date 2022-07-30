# common/users/default.nix

# Inputs to this NixOS module, in this case we are
# using `pkgs` so we can have some user specific packages and config
# to configure the root ssh key.
{ config, pkgs, ... }:

{
  # Setup ZSH to use grml config
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    interactiveShellInit = ''
      source "${pkgs.grml-zsh-config}/etc/zsh/zshrc"
      export FZF_DEFAULT_COMMAND="${pkgs.ripgrep}/bin/rg --files --follow"
      source "${pkgs.fzf}/share/fzf/key-bindings.zsh"
      source "${pkgs.fzf}/share/fzf/completion.zsh"
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
    '';
    # otherwise it'll override the grml prompt
    promptInit = "";
  };

  environment.pathsToLink = [ "/share/zsh" ];

  # Install Neovim and set it as alias for vi(m)
  programs.neovim.enable = true;
  programs.neovim.viAlias = true;

  # Disable sudo prompt for `wheel` users.
  security.sudo.wheelNeedsPassword = false;

  # The block that specifies my user account.
  users.extraUsers.victor = {
    # This account is intended for a non-system user.
    isNormalUser = true;

    # My default shell
    shell = pkgs.zsh;

    # My SSH keys.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFuxekX5WzX4GjbshtjaGyQcvMUgClugnK6T+OYIxw9 victor@null"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC8llUcEBHsLqotFZc++LNP2fjItuuzeUsu5ObXecYNj victor@eevee"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICBhJAp7NWlHgwDYd2z6VNROy5RkeZHRINFLsFvwT4b3 victor@bastion"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIM3TqXaApX2JZsgfZd7PKVFMecDgqTHKibpSzgdXNpYAAAAABHNzaDo= solov2-le"
    ];

    # Make me admin
    extraGroups = [ "systemd-journal" "wheel" ];
  };

  # Configure the root account
  users.extraUsers.root = {
    # Allow my SSH keys for logging in as root.
    openssh.authorizedKeys.keys = config.users.extraUsers.victor.openssh.authorizedKeys.keys;
    # Also use zsh for root
    shell = pkgs.zsh;
  };

  # Setup packages available everywhere
  environment.systemPackages = with pkgs; [ fzf git htop ncdu rsync ripgrep zoxide ];
}
