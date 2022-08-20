{ config, pkgs, ... }: {
  home.username = "victor";
  home.homeDirectory = "/home/victor";
  home.stateVersion = "22.05";

  home.packages = with pkgs; [
    arc-theme
    discord
  ];

  programs.home-manager.enable = true;
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition-bin;
  };
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs; 
  };
}
