{ config, pkgs, lib, inputs, ... }:
{
  programs.home-manager.enable = true;
  home.username = "victor";
  home.homeDirectory = "/home/victor";
  home.stateVersion = "22.05";

  imports = [
    inputs.hyprland.homeManagerModules.default
    ./hyprland
    ./eww
    ./theme.nix
  ];

  home.packages = with pkgs; [
    brightnessctl
    discord
    calibre
    element-desktop-wayland
    fluxcd
    fusee-launcher
    gcc
    gimp
    gnome.eog
    gnome.file-roller
    gnome.gnome-font-viewer
    gnome.nautilus
    grim # Screenshot tool
    k9s
    kubectl
    libnotify
    neofetch
    nixpkgs-review
    python3
    retroarchFull
    ripgrep
    rnix-lsp
    rsync
    rust-analyzer
    rustup
    steam-run
    texlive.combined.scheme-full
    wf-recorder # Screenrecorder
    wl-clipboard # Clipboard manager
    wofi # Wayland rofi

    inputs.riff.packages.x86_64-linux.riff
  ];

  programs.foot = {
    enable = true;
  };

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "Victor";
    userEmail = "victor@xirion.net";
  };

  programs.mako = {
    enable = true;
    borderRadius = 5;
  };

  programs.tmux = {
    enable = true;
    shortcut = "b";
    terminal = "screen-256color";
    clock24 = true;
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition-bin;
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [
      catppuccin.catppuccin-vsc
      james-yu.latex-workshop
      jnoortheen.nix-ide
      matklad.rust-analyzer
      mkhl.direnv
      tamasfe.even-better-toml
      valentjn.vscode-ltex
      vscodevim.vim
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };

  programs.zsh.sessionVariables = {
    DIRENV_LOG_FORMAT = "";
  };

  programs.zsh.enable = true;

  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Pink-Dark";
      package = pkgs.catppuccin-gtk;
    };
    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
    };
    cursorTheme = {
      name = "Catppuccin-Frappe-Pink-Cursors";
      package = pkgs.catppuccin.cursors;
      size = 32;
    };
  };

  services.syncthing.enable = true;
}
