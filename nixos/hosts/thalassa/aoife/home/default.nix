{ lib, config, pkgs, inputs, ... }:
let
  tex = (pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full;
    dnd-5e-latex-template = { pkgs = [ pkgs.v.dnd-5e-latex-template ]; };
  });
in {
  programs.home-manager.enable = true;

  home.username = "victor";
  home.homeDirectory = "/home/victor";
  home.stateVersion = "23.05";

  # # make sure applications show up in Gnome
  # home.activation = {
  #   linkDesktopApplications = {
  #     after = [ "writeBoundary" "createXdgUserDirectories" ];
  #     before = [ ];
  #     data = ''
  #       rm -rf ${config.xdg.dataHome}/"applications/home-manager"
  #       mkdir -p ${config.xdg.dataHome}/"applications/home-manager"
  #       cp -Lr /etc/profiles/per-user/${config.home.username}/share/applications/* ${config.xdg.dataHome}/"applications/home-manager/"
  #     '';
  #   };
  # };

  home.packages = with pkgs; [
    btop
    calibre
    element-desktop-wayland
    fusee-launcher
    gcc
    gimp
    inputs.comma.packages.${pkgs.system}.default
    inputs.riff.packages.${pkgs.system}.riff
    inputs.webcord.packages.${pkgs.system}.default
    mullvad-vpn
    neofetch
    nixfmt
    nixpkgs-review
    python3
    rustup
    solo2-cli
    tex
  ];

  programs.exa = {
    enable = true;
    enableAliases = true;
  };

  programs.bat.enable = true;

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "Victor";
    userEmail = "victor@xirion.net";
    lfs.enable = true;
    delta.enable = true;
    extraConfig = {
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
    };
  };

  programs.tmux = {
    enable = true;
    shortcut = "b";
    terminal = "screen-256color";
    clock24 = true;
  };

  programs.firefox = { enable = true; };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    userSettings = {
      "ltex.language" = "en-GB";
      "latex-workshop" = {
        "linting.chktex.enabled" = true;
        "latex.clean.subfolder.enabled" = true;
        "latex.outDir" = "%TMPDIR%/%RELATIVE_DOC%";
      };
      # "workbench.colorTheme" = "Catppuccin Frappé";
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
        brettm12345.nixfmt-vscode
        # catppuccin.catppuccin-vsc
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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    sessionVariables = { DIRENV_LOG_FORMAT = ""; };
  };

  # xdg.userDirs =
  #   let home = config.home.homeDirectory;
  #   in {
  #     enable = true;
  #     createDirectories = true;
  #     desktop = "${home}/.desktop";
  #     documents = "${home}/cloud/Documents";
  #     download = "${home}/dl";
  #     music = "${home}/cloud/Music";
  #     pictures = "${home}/cloud/Pictures";
  #     publicShare = "${home}/.publicShare";
  #     templates = "${home}/.templates";
  #     videos = "${home}/cloud/Videos";
  #   };

  services.syncthing.enable = true;
}
