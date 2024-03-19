{ pkgs, ... }: {
  # Custom dconf settings
  dconf.settings."org/gnome/desktop/input-sources" = {
    xkb-options = [ "caps:swapescape" ];
  };

  programs.zsh.envExtra = ''
    source ~/.zshrc.secrets
  '';

  home.packages = with pkgs; [
    libreoffice-fresh
    jetbrains.clion
    jetbrains.rust-rover
    eduvpn-client
    localsend
    obsidian
    typst
  ];
}
