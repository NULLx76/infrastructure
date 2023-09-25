{ pkgs, inputs, config, ... }:
let
  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full;
    dnd-5e-latex-template = { pkgs = [ pkgs.v.dnd-5e-latex-template ]; };
  };
  my-python-packages = ps: with ps; [ pandas requests numpy ];
in {
  home.packages = with pkgs; [
    (python3.withPackages my-python-packages)
    btop
    calibre
    celluloid
    cinny-desktop
    element-desktop
    fusee-launcher
    gcc
    gimp
    inputs.attic.packages.${pkgs.system}.attic
    inputs.comma.packages.${pkgs.system}.default
    inputs.webcord.packages.${pkgs.system}.default
    kdenliv
    mattermost-desktop
    mullvad-vpn
    neofetch
    nixfmt
    nixpkgs-review
    plex-media-player
    rustup
    solo2-cli
    tex
    plexamp
    unzip
    yt-dlp
    qmk
  ];

  # Enable my own hm modules
  themes.v.catppuccin.enable = true;
  programs.v.vscode.enable = true;

  programs.riff = {
    enable = true;
    direnv = true;
  };

  programs.firefox.enable = true;

  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    sessionVariables = { DIRENV_LOG_FORMAT = ""; };
  };

  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
    };
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
