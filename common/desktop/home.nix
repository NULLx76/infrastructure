{
  pkgs,
  inputs,
  config,
  ...
}:
let
  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full;
    dnd-5e-latex-template = {
      pkgs = [ pkgs.v.dnd-5e-latex-template ];
    };
  };
  my-python-packages =
    ps: with ps; [
      pandas
      requests
      numpy
      scapy
      pyshark
      cryptography
      flask
      ipwhois
      pyasn
      z3-solver
    ];
in
{
  home.packages = with pkgs; [
    (python3.withPackages my-python-packages)
    btop
    calibre
    celluloid # video player
    cinny-desktop
    element-desktop
    fusee-launcher
    foliate # epub reader
    gcc
    gimp
    inputs.attic.packages.${pkgs.system}.attic
    comma
    discord
    jetbrains.rust-rover
    kdenlive
    libreoffice-fresh
    mattermost-desktop
    neofetch
    nixpkgs-review
    plex-media-player
    plexamp
    spotify
    qmk
    solo2-cli
    tex
    unzip
    yt-dlp
    # z3
  ];

  # Enable my own hm modules
  themes.v.catppuccin.enable = true;
  programs = {
    v = {
      vscode.enable = true;
      nvim.enable = true;
      rust.enable = true;
    };

    firefox.enable = true;

    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    zsh = {
      enable = true;
      sessionVariables = {
        DIRENV_LOG_FORMAT = "";
      };
    };

    thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
      };
    };
    kitty = {
      enable = true;
      shellIntegration.enableZshIntegration = true;
    };
  };
  # Syncthing
  services.syncthing.enable = true;
  xdg.userDirs =
    let
      home = config.home.homeDirectory;
    in
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
}
