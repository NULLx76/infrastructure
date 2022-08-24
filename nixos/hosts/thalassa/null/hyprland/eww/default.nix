{ pkgs, ... }: {
  home.packages = with pkgs; [
    eww-wayland
    brightnessctl
    pamixer
    lua
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  home.file.".config/eww/eww.yuck".source = ./eww.yuck;
  home.file.".config/eww/eww.scss".source = ./eww.scss;

  # scripts
  home.file.".config/eww/scripts/battery.sh" = {
    source = ./scripts/battery.sh;
    executable = true;
  };

  home.file.".config/eww/scripts/volume.sh" = {
    source = ./scripts/volume.sh;
    executable = true;
  };

  home.file.".config/eww/scripts/wifi.sh" = {
    source = ./scripts/wifi.sh;
    executable = true;
  };

  home.file.".config/eww/scripts/workspaces.sh" = {
    source = ./scripts/workspaces.sh;
    executable = true;
  };

  home.file.".config/eww/scripts/workspaces.lua" = {
    source = ./scripts/workspaces.lua;
    executable = true;
  };
}
