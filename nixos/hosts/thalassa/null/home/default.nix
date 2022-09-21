{ config, pkgs, lib, inputs, ... }:
{
  programs.home-manager.enable = true;
  home.username = "victor";
  home.homeDirectory = "/home/victor";
  home.stateVersion = "22.05";

  imports = [
    inputs.hyprland.homeManagerModules.default
    ./hyprland.nix
    ./eww
    ./theme.nix
  ];

  home.packages = with pkgs; [
    brightnessctl
    btop
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
    inputs.riff.packages.${pkgs.system}.riff
    inputs.webcord.packages.${pkgs.system}.default
    k9s
    kubectl
    libnotify
    neofetch
    networkmanagerapplet
    nixpkgs-review
    plexamp
    plex-media-player
    pulseview
    python3
    retroarchFull
    ripgrep
    rnix-lsp
    rsync
    rust-analyzer
    rustup
    saleae-logic-2
    solo2-cli
    steam-run
    texlive.combined.scheme-full
    wf-recorder # Screenrecorder
    wl-clipboard # Clipboard manager
    wofi # Wayland rofi
  ];

  programs.foot = {
    enable = true;
  };

  programs.exa = {
    enable = true;
    enableAliases = true;
  };

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "Victor";
    userEmail = "victor@xirion.net";
  };

  programs.mako = {
    enable = true;
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
    # profiles.dev-edition-default = {
    #   isDefault = true;
    # };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [
      catppuccin.catppuccin-vsc
      codezombiech.gitignore
      editorconfig.editorconfig
      james-yu.latex-workshop
      jnoortheen.nix-ide
      matklad.rust-analyzer
      mkhl.direnv
      ms-vscode.cpptools
      tamasfe.even-better-toml
      valentjn.vscode-ltex
      vscodevim.vim
      xaver.clang-format
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };

  programs.zsh = {
    enable = true;
    sessionVariables = {
      DIRENV_LOG_FORMAT = "";
    };
  };

  xdg.userDirs = let home = config.home.homeDirectory; in
    {
      enable = true;
      createDirectories = true;
      desktop = "${home}/.desktop";
      documents = "${home}/cloud/Documents";
      download = "${home}/dl";
      music = "${home}/cloud/Music";
      pictures = "${home}/cloud/Pictures";
      publicShare = "${home}/.publicShare";
      templates = "${home}/.templates";
      videos = "${home}/cloud/Videos";
    };

  services.syncthing.enable = true;
}
