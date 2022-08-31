{ config, pkgs, lib, fetchFromGithub, ... }:
{
  programs.home-manager.enable = true;
  home.username = "victor";
  home.homeDirectory = "/home/victor";
  home.stateVersion = "22.05";

  imports = [
    ./hyprland
    ./eww
  ];

  home.packages = with pkgs; [
    brightnessctl
    discord
    calibre
    element-desktop-wayland
    fluxcd
    fusee-launcher
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
  ];

  programs.foot = {
    enable = true;
    # Note, pink and blue are switched
    settings.colors = {
      foreground = "c6d0f5"; # Text
      background = "303446"; # Base
      regular0 = "51576d"; # Surface 1
      regular1 = "e78284"; # red
      regular2 = "a6d189"; # green
      regular3 = "e5c890"; # yellow
      regular4 = "f4b8e4"; # pink
      regular5 = "8caaee"; # blue
      regular6 = "81c8be"; # teal
      regular7 = "b5bfe2"; # Subtext 1
      bright0 = "626880"; # Surface 2
      bright1 = "e78284"; # red
      bright2 = "a6d189"; # green
      bright3 = "e5c890"; # yellow
      bright4 = "f4b8e4"; # pink
      bright5 = "8caaee"; # blue
      bright6 = "81c8be"; # teal
      bright7 = "a5adce"; # Subtext 0
    };
  };

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "Victor";
    userEmail = "victor@xirion.net";
  };

  programs.mako = {
    enable = true;
    backgroundColor = "#292c3c";
    borderRadius = 5;
    borderColor = "#f4b8e4";
    textColor = "#c6d0f5";
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
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
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
