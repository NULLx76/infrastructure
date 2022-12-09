{ lib, config, pkgs, inputs, ... }:
let
  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full;
    dnd-5e-latex-template = { pkgs = [ pkgs.v.dnd-5e-latex-template ]; };
  };
in {
  programs.home-manager.enable = true;

  home.username = "victor";
  home.homeDirectory = "/home/victor";
  home.stateVersion = "23.05";

  imports = [ ./dconf.nix ./theme.nix ./neovim.nix ];

  home.packages = with pkgs; [
    btop
    calibre
    element-desktop
    fusee-launcher
    gcc
    gimp
    inputs.comma.packages.${pkgs.system}.default
    inputs.riff.packages.${pkgs.system}.riff
    inputs.webcord.packages.${pkgs.system}.default
    jetbrains.clion
    jetbrains.idea-ultimate
    mullvad-vpn
    neofetch
    nixfmt
    nixpkgs-review
    python3
    rustup
    solo2-cli
    tex
  ];

  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "text/html" = "firefox.desktop";
    "text/plain" = "org.gnome.TextEditor.desktop";
    "application/pdf" = "org.gnome.Evince.desktop";

    # Images
    "image/bmp" = "org.gnome.eog.desktop";
    "image/gif" = "org.gnome.eog.desktop";
    "image/jpg" = "org.gnome.eog.desktop";
    "image/pjpeg" = "org.gnome.eog.desktop";
    "image/png" = "org.gnome.eog.desktop";
    "image/tiff" = "org.gnome.eog.desktop";
    "image/webp" = "org.gnome.eog.desktop";
    "image/x-bmp" = "org.gnome.eog.desktop";
    "image/x-gray" = "org.gnome.eog.desktop";
    "image/x-icb" = "org.gnome.eog.desktop";
    "image/x-ico" = "org.gnome.eog.desktop";
    "image/x-png" = "org.gnome.eog.desktop";
    "image/x-portable-anymap" = "org.gnome.eog.desktop";
    "image/x-portable-bitmap" = "org.gnome.eog.desktop";
    "image/x-portable-graymap" = "org.gnome.eog.desktop";
    "image/x-portable-pixmap" = "org.gnome.eog.desktop";
    "image/x-xbitmap" = "org.gnome.eog.desktop";
    "image/x-xpixmap" = "org.gnome.eog.desktop";
    "image/x-pcx" = "org.gnome.eog.desktop";
    "image/svg+xml" = "org.gnome.eog.desktop";
    "image/svg+xml-compressed" = "org.gnome.eog.desktop";
    "image/vnd.wap.wbmp" = "org.gnome.eog.desktop";
    "image/x-icns" = "org.gnome.eog.desktop";
  };

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

  programs.firefox.enable = true;

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    userSettings = {
      "ltex.language" = "en-GB";
      "latex-workshop.linting.chktex.enabled" = true;
      "latex-workshop.latex.clean.subfolder.enabled" = true;
      "latex-workshop.latex.outDir" = "%TMPDIR%/%RELATIVE_DOC%";
      "editor.fontFamily" =
        "'DejaVuSansMono Nerd Font', 'monospace', monospace";
      "keyboard.dispatch" = "keyCode";
      "rust-analyzer.server.path" = "${pkgs.rust-analyzer}/bin/rust-analyzer";
      "terminal.integrated.defaultProfile.linux" = "zsh";
      "nix.enableLanguageServer" = true; # Enable LSP.
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
      "[nix]" = { "editor.defaultFormatter" = "brettm12345.nixfmt-vscode"; };
      # Don't index unecessary things
      "files.exclude" = {
        "**/.vscode" = true;
        "**/.git" = true;
        "**/.svn" = true;
        "**/.hg" = true;
        "**/.deps" = true;
        "**/CVS" = true;
        "**/.DS_Store" = true;
        "/bin" = true;
        "/boot" = true;
        "/cdrom" = true;
        "/dev" = true;
        "/proc" = true;
        "/etc" = true;
        "/nix" = true;
      };
    };
    extensions = with pkgs.vscode-extensions;
      with pkgs.v.vscode-extensions; [
        brettm12345.nixfmt-vscode
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
