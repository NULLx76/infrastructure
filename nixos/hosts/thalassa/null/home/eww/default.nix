{ pkgs, ... }: {
  home.packages = with pkgs; [
    eww-wayland
    pamixer
    lua
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  home.file.".config/eww/eww.yuck".source = ./eww.yuck;
  home.file.".config/eww/eww.scss".text = builtins.readFile ./eww.scss;

  # scripts 
  # TODO: just link all scripts in ./scripts to .config/eww/scripts
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

  home.file.".config/eww/scripts/do-not-disturb.sh" = {
    source = ./scripts/do-not-disturb.sh;
    executable = true;
  };
}
