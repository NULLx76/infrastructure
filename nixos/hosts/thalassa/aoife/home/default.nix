_: {
  # Custom dconf settings
  dconf.settings."org/gnome/desktop/input-sources" = {
    xkb-options = [ "caps:swapescape" ];
  };

  programs.zsh.envExtra = ''
    source ~/.zshrc.secrets
  '';
}
