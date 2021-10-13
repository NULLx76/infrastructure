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
      source "${pkgs.fzf}/share/fzf/key-bindings.zsh"
      source "${pkgs.fzf}/share/fzf/completion.zsh"
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
    '';
    # otherwise it'll override the grml prompt
    promptInit = "";
  };
  
  environment.pathsToLink = [ "/share/zsh" ];

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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDC3alaexJkUAi/81weIGGTNrkRf+x0UT0wTWNENOc8bakmgzPg0STopCwHYAHoNHDC1dorVpVfCqWsAx9ta9KOCvqo3BS7rOWlASSna2fejvnNZAy6yzdvWq8Bclg7U40ic8ubnLw7l9nompHk7kzwVN6a6wqVfM5aefEXpaE4rlXu56yF81RR1TaWMnTvD7JMzyeDHt29DPdw+/ivOy3SXC8lUOukQLycNYduBO911gegkKH7mRNrqgYCuV6PF38CZPAhboC0JbpMKsiHInfY6iTrST035JIuVfEG0oRlW7BSsSfafPBlstyvf63mjjCJ13/47PyvkxWB47UYtYUjtQvrlzQtGlxyljyARL6x6RC6WY2Hluej4kWRVrJNRtDZAx+AeYa2jgUeD+RWPUQuXYLXs+0F1A7/y/m3FiuBMpB6neptX/jRY7aI1XDZiO23Pyui0pCsl9c8PQFltwvL1N32miRGhA/2DPhrKgpLRcRNglwRPZSkc+3er1cuUrs= victor@eevee"
      "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAjJmG5W+uO+KTOmzknOfzkjbCtOCpO9tSxLN2BG6hxCsKPN1U31WDiajeHrZFselpWG80710Ne3wAlWduU3aUTeXdms0N99F7CbIFHXRqU0aEu4FN3WDuv0bRLoc+Ern9V7R4DvtxyNFd66yLzvzfT2/0nudiIkWV6W8qF4W6wJF+/TVTYcwZzVTBfpqUG9LMyMB1e6c0DYISmIGT0Q5s0sb2Hrs5Xa2Q7vgAevHJJzPojGQ+zcK/nHos4/glnDGoj9iyj55zB48LycLxjpFL9GAZfBZPi0SXVRy3gEVPkeger0e4OSumYiEbZhcV3MdtffSIHmq3ehgXi0FyBeMhsw== victor@xirion.net"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMMbdjysLnmwJD5Fs/SjBPstdIQNUxy8zFHP0GlhHMJB victor@bastion"
    ];

    # Make me admin
    extraGroups = [ "wheel" ];
  };

  # Configure the root account
  users.extraUsers.root = {
    # Allow my SSH keys for logging in as root.
    openssh.authorizedKeys.keys = config.users.users.victor.openssh.authorizedKeys.keys;
    # Also use zsh for root
    shell = pkgs.zsh;
  };

  # Setup packages available everywhere
  environment.systemPackages = with pkgs; [
    fzf
    git
    htop
    rsync
    neovim
    zoxide
  ];
}
