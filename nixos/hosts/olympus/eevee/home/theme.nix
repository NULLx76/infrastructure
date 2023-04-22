{ lib, pkgs, config, ... }:
let
  theme = "Catppuccin-Pink-Dark";
  cursorTheme = config.home.pointerCursor.name;
in {
  home.pointerCursor = {
    name = "Bibata_Ghost";
    size = 24;
    package = pkgs.bibata-cursors-translucent;
  };

  gtk = {
    enable = true;
    theme = {
      name = theme;
      package = pkgs.catppuccin-gtk;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme.override { color = "violet"; };
    };
    cursorTheme = {
      name = cursorTheme;
      inherit (config.home.pointerCursor) package size;
    };
  };

  programs.vscode = {
    userSettings."workbench.colorTheme" = "Catppuccin Frappé";
    extensions = [ pkgs.vscode-extensions.catppuccin.catppuccin-vsc ];
  };
}
