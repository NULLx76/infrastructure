{ config, pkgs, inputs, texlive, ... }:
let
  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full;
    dnd-5e-latex-template = { pkgs = [ pkgs.v.dnd-5e-latex-template ]; };
  };
in
{
  programs = {
    home-manager.enable = true;

    foot = { enable = true; };

    nix-index.enable = true;

    exa = {
      enable = true;
      enableAliases = true;
    };

    bat.enable = true;

    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      userName = "Vivian";
      userEmail = "vivian@0x76.dev";
      lfs.enable = true;
      # delta.enable = true;
      extraConfig = {
        push.autoSetupRemote = true;
        init.defaultBranch = "main";
      };
    };

    mako = {
      enable = true;
      extraConfig = ''
        [mode=do-not-disturb]
        invisible=1
      '';
    };

    tmux = {
      enable = true;
      shortcut = "b";
      terminal = "screen-256color";
      clock24 = true;
    };

    firefox = {
      enable = true;
      package = pkgs.firefox-devedition-bin;
    };

    vscode = {
      enable = true;
      package = pkgs.vscode;
      userSettings = {
        "ltex.language" = "en-GB";
        "latex-workshop" = {
          "linting.chktex.enabled" = true;
          "latex.clean.subfolder.enabled" = true;
          "latex.outDir" = "%TMPDIR%/%RELATIVE_DOC%";
        };
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
      };
      extensions = with pkgs.vscode-extensions;
        with pkgs.v.vscode-extensions; [
          # astro-build.astro-vscode
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
          redhat.vscode-yaml
          tamasfe.even-better-toml
          valentjn.vscode-ltex
          vscodevim.vim
          xaver.clang-format
        ];
    };

    direnv = {
      enable = true;
      nix-direnv = { enable = true; };
    };

    zsh = {
      enable = true;
      sessionVariables = { DIRENV_LOG_FORMAT = ""; };
    };
  };
  home = {
    username = "vivian";
    homeDirectory = "/home/vivian";
    stateVersion = "22.05";

    packages = with pkgs; [
      appimage-run
      brightnessctl
      btop
      calibre
      cinny-desktop
      discord-canary
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
      inputs.webcord.packages.${pkgs.system}.default
      k9s
      kubectl
      libnotify
      mullvad-vpn
      neofetch
      nixpkgs-review
      nixfmt
      ouch
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
      v.deemix-gui
      wf-recorder # Screenrecorder
      wl-clipboard # Clipboard manager
      wofi # Wayland rofi
      wpa_supplicant_gui
    ];
  };

  imports = [ ./hyprland.nix ./neovim.nix ./eww ./theme.nix ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let browser = [ "firefox.desktop" ];
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

  xdg.userDirs =
    let home = config.home.homeDirectory;
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
