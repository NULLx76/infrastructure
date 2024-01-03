{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      eww-wayland
      pamixer
      lua
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
    file = {

      ".config/eww/eww.yuck".source = ./eww.yuck;
      ".config/eww/eww.scss".text = builtins.readFile ./eww.scss;

      # scripts
      # TODO: just link all scripts in ./scripts to .config/eww/scripts
      ".config/eww/scripts/volume.sh" = {
        source = ./scripts/volume.sh;
        executable = true;
      };

      ".config/eww/scripts/wifi.sh" = {
        source = ./scripts/wifi.sh;
        executable = true;
      };

      ".config/eww/scripts/workspaces.sh" = {
        source = ./scripts/workspaces.sh;
        executable = true;
      };

      ".config/eww/scripts/workspaces.lua" = {
        source = ./scripts/workspaces.lua;
        executable = true;
      };

      ".config/eww/scripts/do-not-disturb.sh" = {
        source = ./scripts/do-not-disturb.sh;
        executable = true;
      };
    };
  };
}
