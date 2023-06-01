{ pkgs, inputs, config, ... }:
let
  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full;
    dnd-5e-latex-template = { pkgs = [ pkgs.v.dnd-5e-latex-template ]; };
  };
  my-python-packages = ps: with ps; [ pandas requests numpy ];
in {
  home.packages = with pkgs; [
    btop
    calibre
    celluloid
    chromium
    element-desktop
    fusee-launcher
    gcc
    gimp
    inputs.comma.packages.${pkgs.system}.default
    inputs.webcord.packages.${pkgs.system}.default
    # jetbrains.clion
    kdenlive
    mullvad-vpn
    neofetch
    nixfmt
    nixpkgs-review
    (python3.withPackages my-python-packages)
    plex-media-player
    rustup
    solo2-cli
    tex
    unzip
    yt-dlp
    qmk
  ];

  # Enable my own hm modules
  themes.v.catppuccin.enable = true;
  programs.v.nvim.enable = true;
  programs.v.vscode.enable = true;

  programs.riff = {
    enable = true;
    direnv = true;
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
    # delta.enable = true;
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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    sessionVariables = { DIRENV_LOG_FORMAT = ""; };
  };

  # Syncthing
  services.syncthing.enable = true;
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
}
