{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./laura.nix
    ./vivian.nix
    ./jonathan.nix
  ];
  programs = {

    # Setup ZSH to use grml config
    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      autosuggestions.enable = true;
      interactiveShellInit = ''
        source "${pkgs.grml-zsh-config}/etc/zsh/zshrc"
        export FZF_DEFAULT_COMMAND="${pkgs.ripgrep}/bin/rg --files --follow"
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_CTRL_R_COMMAND="$FZF_DEFAULT_COMMAND"
        eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
        eval "$(${pkgs.fzf}/bin/fzf --zsh)"

        export TEMPDIRS="$HOME/tmp"
        source "${inputs.t.packages.${pkgs.system}.default}/bin/t-rs.sh"
      '';
      # otherwise it'll override the grml prompt
      # promptInit = lib.mkDefault "";
    };

    # Install Neovim and set it as alias for vi(m)
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
    };
  };

  environment.pathsToLink = [ "/share/zsh" ];

  # Disable sudo prompt for `wheel` users.
  security.sudo.wheelNeedsPassword = lib.mkDefault false;

  # Configure the root account
  users.extraUsers.root = {
    # Allow my SSH keys for logging in as root.
    openssh.authorizedKeys.keys = config.users.extraUsers.vivian.openssh.authorizedKeys.keys;
    # Also use zsh for root
    shell = pkgs.zsh;
  };

  # Setup packages available everywhere
  environment.systemPackages = with pkgs; [
    file
    fzf
    git
    htop
    ncdu
    psmisc
    helix
    ripgrep
    rsync
    zoxide

    # Terminfo
    pkgs.kitty.terminfo
  ];

  programs.tmux = {
    enable = true;
    withUtempter = true;
    terminal = "tmux-256color";
    secureSocket = false;
    extraConfig = ''
      set -g mouse on
      setw -g mouse on
    '';
  };
}
