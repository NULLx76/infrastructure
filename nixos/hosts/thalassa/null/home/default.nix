{ config, pkgs, lib, fetchFromGithub, ... }:
let
  rofi = fetchTarball {
    url = "https://github.com/adi1090x/rofi/archive/refs/heads/master.zip";
    sha256 = "0wq8v758gnk1wjdqyqmda5rlxlpv33l3sdf3rb3nx834vc5hr1rn";
  };
in
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
  ];

  programs.alacritty = {
    enable = true;
  };

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

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition-bin;
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [
      matklad.rust-analyzer
      mkhl.direnv
      jnoortheen.nix-ide
      james-yu.latex-workshop
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
      name = "Catppuccin-Purple-Dark";
      package = pkgs.catppuccin-gtk;
    };
    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
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
