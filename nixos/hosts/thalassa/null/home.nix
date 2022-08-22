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
    rustup
    rust-analyzer
    steam-run
    texlive.combined.scheme-full
  ];

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "Victor";
    userEmail = "victor@xirion.net";
  };

  programs.tmux = {
    enable = true;
    shortcut = "b";
    terminal = "screen-256color";
    clock24 = true;
  };

  programs.home-manager.enable = true;
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition-bin;
  };
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [
      matklad.rust-analyzer
      jnoortheen.nix-ide
      james-yu.latex-workshop
      valentjn.vscode-ltex
    ];
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
