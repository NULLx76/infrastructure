{ config, pkgs, lib, inputs, texlive, ... }:
let
  tex = (pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full;
    dnd-5e-latex-template = { pkgs = [ pkgs.v.dnd-5e-latex-template ]; };
  });
in {
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
    appimage-run
    brightnessctl
    btop
    calibre
    cinny-desktop
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
    inputs.comma.packages.${pkgs.system}.default
    inputs.riff.packages.${pkgs.system}.riff
    inputs.webcord.packages.${pkgs.system}.default
    k9s
    kubectl
    libnotify
    neofetch
    nixpkgs-review
    plex-media-player
    plexamp
    python3
    retroarchFull
    ripgrep
    rsync
    rustup
    saleae-logic-2
    solo2-cli
    steam-run
    tex
    thunderbird-wayland
    wf-recorder # Screenrecorder
    wl-clipboard # Clipboard manager
    wofi # Wayland rofi
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = let browser = [ "firefox.desktop" ];
    in {
      "image/*" = "org.gnome.eog.desktop";
      "text/html" = browser;
      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "x-scheme-handler/ftp" = browser;
      "x-scheme-handler/about" = browser;
      "x-scheme-handler/unknown" = browser;
      "application/x-extension-htm" = browser;
      "application/x-extension-html" = browser;
      "application/x-extension-shtml" = browser;
      "application/xhtml+xml" = browser;
      "application/x-extension-xhtml" = browser;
      "application/x-extension-xht" = browser;

      "application/json" = browser;
      "application/pdf" = browser;

      "x-scheme-handler/vscode" = "code-url-handler.desktop";
      "x-scheme-handler/discord" = "webcord.desktop";
    };
  };

  programs.foot = { enable = true; };

  programs.nix-index.enable = true;

  programs.exa = {
    enable = true;
    enableAliases = true;
  };

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "Victor";
    userEmail = "victor@xirion.net";
    lfs.enable = true;
  };

  programs.mako = {
    enable = true;
    extraConfig = ''
      [mode=do-not-disturb]
      invisible=1
    '';
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
    userSettings = {
      "ltex.language" = "en-GB";
      "workbench.colorTheme" = "Catppuccin Frappé";
      "editor.fontFamily" =
        "'DejaVuSansMono Nerd Font', 'monospace', monospace";
      "keyboard.dispatch" = "keyCode";
      "rust-analyzer.server.path" = "${pkgs.rust-analyzer}/bin/rust-analyzer";
      "terminal.integrated.defaultProfile.linux" = "zsh";
      "nix.enableLanguageServer" = true; # Enable LSP.
      "nix.serverPath" =
        "${pkgs.nil}/bin/nil"; # The path to the LSP server executable.
      "[nix]" = { "editor.defaultFormatter" = "brettm12345.nixfmt-vscode"; };
      # "platformio-ide.useBuiltinPIOCore" = false;
      # "platformio-ide.useBuiltinPython" = false;
    };
    extensions = with pkgs.vscode-extensions;
      with pkgs.v.vscode-extensions; [
        brettm12345.nixfmt-vscode
        catppuccin.catppuccin-vsc
        codezombiech.gitignore
        editorconfig.editorconfig
        foxundermoon.shell-format
        james-yu.latex-workshop
        jnoortheen.nix-ide
        matklad.rust-analyzer
        mkhl.direnv
        ms-vscode-remote.remote-ssh
        ms-vscode.cpptools
        platformio.platformio-ide
        tamasfe.even-better-toml
        valentjn.vscode-ltex
        vscodevim.vim
        xaver.clang-format
      ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv = { enable = true; };
  };

  programs.zsh = {
    enable = true;
    sessionVariables = { DIRENV_LOG_FORMAT = ""; };
  };

  xdg.userDirs = let home = config.home.homeDirectory;
  in {
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
