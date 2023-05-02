_: {
  programs.home-manager.enable = true;

  home.username = "victor";
  home.homeDirectory = "/home/victor";
  home.stateVersion = "23.05";

  imports = [ ../../../../common/desktop/home.nix ];

  # Custom dconf settings
  dconf.settings."org/gnome/desktop/input-sources" = {
    xkb-options = [ "caps:swapescape" ];
  };

  programs.zsh.envExtra = ''
    source ~/.zshrc.secrets
  '';
}
