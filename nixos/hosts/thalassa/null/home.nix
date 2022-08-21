{ config, pkgs, ... }: {
  home.username = "victor";
  home.homeDirectory = "/home/victor";
  home.stateVersion = "22.05";

  home.packages = with pkgs; [
    discord
    rnix-lsp
    fusee-launcher
    neofetch
    fluxcd
    k9s
    kubectl
    nixpkgs-review
    ripgrep
    rsync
    tmux
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

  gtk = {
    enable = true;
    theme = {
      name = "Arc-Darker";
      package = pkgs.arc-theme;
    };
  };

  services.syncthing.enable = true;
}
