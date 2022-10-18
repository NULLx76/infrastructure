{ config, pkgs, lib, ... }: {
  programs.home-manager.enable = true;
  home.username = "victor";
  home.homeDirectory = "/home/victor";
  home.stateVersion = "22.05";

  programs.direnv = {
    enable = true;
    nix-direnv = { enable = true; };
  };

  programs.zsh = {
    enable = true;
    sessionVariables = { DIRENV_LOG_FORMAT = ""; };
  };
}
