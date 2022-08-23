{ config, pkgs, lib, ... }: {
  home.username = "victor";
  home.homeDirectory = "/home/victor";
  home.stateVersion = "22.05";

  imports = [
    ./dconf.nix
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
    peek
  ];

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

  programs.home-manager.enable = true;
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
      name = "Arc-Darker";
      package = pkgs.arc-theme;
    };
  };

  services.syncthing.enable = true;

  # dconf.settings =
  #   let
  #     inherit (builtins) length head tail listToAttrs genList;
  #     range = a: b: if a < b then [ a ] ++ range (a + 1) b else [ ];
  #     globalPath = "org/gnome/settings-daemon/plugins/media-keys";
  #     path = "${globalPath}/custom-keybindings";
  #     mkPath = id: "${globalPath}/custom${toString id}";
  #     isEmpty = list: length list == 0;
  #     mkSettings = settings:
  #       let
  #         checkSettings = { name, command, binding }@this: this;
  #         aux = i: list:
  #           if isEmpty list then [ ] else
  #           let
  #             hd = head list;
  #             tl = tail list;
  #             name = mkPath i;
  #           in
  #           aux (i + 1) tl ++ [{
  #             name = mkPath i;
  #             value = checkSettings hd;
  #           }];
  #         settingsList = (aux 0 settings);
  #       in
  #       listToAttrs (settingsList ++ [
  #         {
  #           name = globalPath;
  #           value = {
  #             custom-keybindings = genList (i: "/${mkPath i}/") (length settingsList);
  #           };
  #         }
  #       ]);
  #   in
  #   mkSettings [
  #     {
  #       name = "Open Terminal";
  #       command = "kgx";
  #       binding = "<Super>Return";
  #     }
  #   ];
}
