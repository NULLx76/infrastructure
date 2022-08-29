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
    retroarchFull
    python3
    element-desktop-wayland

    gnome.gnome-font-viewer

    wofi # Wayland rofi
    grim # Screenshot tool
    wf-recorder # Screenrecorder
    wl-clipboard # Clipboard manager
    networkmanager_dmenu
    brightnessctl
    libnotify
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

  home.file.".config/networkmanager-dmenu/config.ini".text = ''
    [dmenu]
    dmenu_command = wofi --dmenu -i
    # # Note that dmenu_command can contain arguments as well like:
    # # `dmenu_command = rofi -dmenu -i -theme nmdm`
    # # `dmenu_command = rofi -dmenu -width 30 -i`
    # # `dmenu_command = dmenu -i -l 25 -b -nb #909090 -nf #303030`
    # (Default: False) use rofi highlighting instead of '=='
    rofi_highlight = true
    # compact = <True or False> # (Default: False). Remove extra spacing from display
    # pinentry = <Pinentry command>  # (Default: None) e.g. `pinentry-gtk`
    # wifi_chars = <string of 4 unicode characters representing 1-4 bars strength>
    wifi_chars = ▂▄▆█
    # list_saved = <True or False> # (Default: False) list saved connections

    [dmenu_passphrase]
    # # Uses the -password flag for Rofi, -x for bemenu. For dmenu, sets -nb and
    # # -nf to the same color or uses -P if the dmenu password patch is applied
    # # https://tools.suckless.org/dmenu/patches/password/
    # obscure = True
    # obscure_color = #222222

    [editor]
    # terminal = <name of terminal program>
    terminal = alacritty
    # gui_if_available = <True or False> (Default: True)
  '';
}
