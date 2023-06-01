_: {
  programs.direnv = {
    enable = true;
    nix-direnv = { enable = true; };
  };

  programs.zsh = {
    enable = true;
    sessionVariables = { DIRENV_LOG_FORMAT = ""; };
  };
}
