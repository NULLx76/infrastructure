{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ./laura.nix
    ./victor.nix
  ];

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
  programs.neovim = {
    enable = true;
    viAlias = true;
  };

  # Disable sudo prompt for `wheel` users.
  security.sudo.wheelNeedsPassword = lib.mkDefault false;

  # Configure the root account
  users.extraUsers.root = {
    # Allow my SSH keys for logging in as root.
    openssh.authorizedKeys.keys = config.users.extraUsers.victor.openssh.authorizedKeys.keys;
    # Also use zsh for root
    shell = pkgs.zsh;
  };

  # Setup packages available everywhere
  environment.systemPackages = with pkgs; [
    fzf
    git
    htop
    ncdu
    psmisc
    ripgrep
    rsync
    zoxide
  ];
}
