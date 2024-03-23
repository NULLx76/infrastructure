{ pkgs, ... }: {
  home.file.".config/hypr/hyprland.conf".source = ./hyprland.conf;
  home.packages = with pkgs;  [
    wofi
  ];

}
