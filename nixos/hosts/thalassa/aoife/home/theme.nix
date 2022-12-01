{ lib, pkgs, config, ... }:
let
  theme = "Catppuccin-Pink-Dark";
  cursorTheme = config.home.pointerCursor.name;
in {
  home.pointerCursor = {
    name = "Catppuccin-Frappe-Pink-Cursors";
    size = 32;
    package = pkgs.catppuccin-cursors.frappePink;
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
      package = config.home.pointerCursor.package;
      size = config.home.pointerCursor.size;
    };
  };

  programs.vscode = {
    userSettings."workbench.colorTheme" = "Catppuccin Frappé";
    extensions = [ pkgs.vscode-extensions.catppuccin.catppuccin-vsc ];
  };
}
